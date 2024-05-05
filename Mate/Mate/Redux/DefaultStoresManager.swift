//
//  DefaultStoresManager.swift
//  Mate
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Combine
import Foundation
import FiableRedux
import MateNetworking
import KeychainAccess
import WidgetKit
import UIKit

// MARK: - DefaultStoresManager
//
class DefaultStoresManager: StoresManager {

    private let sessionManagerLockQueue = DispatchQueue(label: "StoresManager.sessionManagerLockQueue")

    /// SessionManager: Persistent Storage for Session-Y Properties.
    /// Private property. To be only accessed through `sessionManager` to make
    /// access thread safe.
    /// This seems to fix a crash:
    /// `Thread 1: Simultaneous accesses to <MEMORY_ADDESS>, but modification requires exclusive access`
    /// https://github.com/woocommerce/woocommerce-ios/issues/878
    private var _sessionManager: SessionManagerProtocol

    private let defaults: UserDefaults

    /// Keychain access. Used for sharing the auth access token with the widgets extension.
    ///
    private lazy var keychain = Keychain(service: FiableConstants.keychainServiceName)

    /// Observes application password generation failure notification
    ///
    private var applicationPasswordGenerationFailureObserver: NSObjectProtocol?

    /// Observes invalid WPCOM token notification
    ///
    private var invalidWPCOMTokenNotificationObserver: NSObjectProtocol?

    /// NotificationCenter
    ///
    private let notificationCenter: NotificationCenter

    /// SessionManager: Persistent Storage for Session-Y Properties.
    /// This property is thread safe
    private(set) var sessionManager: SessionManagerProtocol {
        get {
            return sessionManagerLockQueue.sync {
                return _sessionManager
            }
        }

        set {
            sessionManagerLockQueue.sync {
                _sessionManager = newValue
            }
        }
    }

    /// Active StoresManager State.
    ///
    private var state: StoresManagerState {
        willSet {
            state.willLeave()
        }
        didSet {
            state.didEnter()
            isLoggedIn = isAuthenticated
        }
    }

    /// Indicates if the StoresManager is currently authenticated, or not.
    ///
    var isAuthenticated: Bool {
        return state is AuthenticatedState
    }

    /// Indicates if the StoresManager is currently authenticated with site credentials only.
    ///
    var isAuthenticatedWithoutWPCom: Bool {
        guard let credentials = sessionManager.defaultCredentials else {
            return false
        }
        if case .wpcom = credentials {
            return false
        }
        return true
    }

    @Published private var isLoggedIn: Bool = false

    var isLoggedInPublisher: AnyPublisher<Bool, Never> {
        $isLoggedIn
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Indicates if we need a Default StoreID, or there's one already set.
    ///
    var needsDefaultStore: Bool {
        return true//sessionManager.defaultStoreID == nil
    }

    var needsDefaultStorePublisher: AnyPublisher<Bool, Never> {
        sessionManager.defaultStoreIDPublisher
            .map { $0 == nil }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var siteID: AnyPublisher<Int64?, Never> {
        sessionManager.defaultStoreIDPublisher
    }

//    var site: AnyPublisher<Site?, Never> {
//        sessionManager.defaultSitePublisher
//    }

    /// Designated Initializer
    ///
    init(sessionManager: SessionManagerProtocol,
         notificationCenter: NotificationCenter = .default,
         defaults: UserDefaults = .standard) {
        _sessionManager = sessionManager
        self.state = AuthenticatedState(sessionManager: sessionManager) ?? DeauthenticatedState()
        self.notificationCenter = notificationCenter
        self.defaults = defaults

        isLoggedIn = isAuthenticated

        fullyDeauthenticateIfNeeded()
        restoreSessionAccountIfPossible()
//        restoreSessionSiteIfPossible()
    }


    /// Forwards the Action to the current State.
    ///
    func dispatch(_ action: Action) {
        state.onAction(action)
    }

    /// Forwards the Actions to the current State.
    ///
    func dispatch(_ actions: [Action]) {
        for action in actions {
            state.onAction(action)
        }
    }

    /// Switches the internal state to Authenticated.
    ///
    @discardableResult
    func authenticate(credentials: Credentials) -> StoresManager {
        state = AuthenticatedState(credentials: credentials)
        sessionManager.defaultCredentials = credentials

        listenToApplicationPasswordGenerationFailureNotification()
        listenToWPCOMInvalidWPCOMTokenNotification()

        return self
    }

    /// De-authenticates upon receiving `ApplicationPasswordsGenerationFailed` notification
    ///
    func listenToApplicationPasswordGenerationFailureNotification() {
        applicationPasswordGenerationFailureObserver = notificationCenter.addObserver(forName: .ApplicationPasswordsGenerationFailed,
                                                                                      object: nil,
                                                                                      queue: .main) { [weak self] note in
            _ = self?.deauthenticate()
        }
    }

    /// De-authenticates upon receiving `RemoteDidReceiveInvalidTokenError` notification
    ///
    func listenToWPCOMInvalidWPCOMTokenNotification() {
        invalidWPCOMTokenNotificationObserver = notificationCenter.addObserver(forName: .RemoteDidReceiveInvalidTokenError,
                                                                               object: nil,
                                                                               queue: .main) { [weak self] note in
            _ = self?.deauthenticate()     
            
//            ServiceLocator.stores.deauthenticate()
        }
    }

    /// Synchronizes all of the Session's Entities.
    ///
    @discardableResult
    func synchronizeEntities(onCompletion: (() -> Void)? = nil) -> StoresManager {
        let group = DispatchGroup()

        group.enter()
        synchronizeAccount { [weak self] _ in
            group.enter()
            self?.synchronizeAccountSettings { _ in
                group.leave()
            }
            group.leave()
        }

        group.notify(queue: .main) {
            onCompletion?()
        }

        return self
    }
    
    /// Synchronizes the WordPress.com Account Settings, associated with the current credentials.
    ///
    func synchronizeAccountSettings(onCompletion: @escaping (Result<Void, Error>) -> Void) {
        guard let userID = sessionManager.defaultAccount?.userID else {
            onCompletion(.failure(StoresManagerError.missingDefaultSite))
            return
        }
//
        let action = AccountAction.synchronizeAccountSettings(userID: userID) { [weak self] result in
            switch result {
            case .success(let accountSettings):
                if let self = self, self.isAuthenticated {
                    // Save the user's preference
//                    ServiceLocator.analytics.setUserHasOptedOut(accountSettings.tracksOptOut)
                }
                onCompletion(.success(()))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }

        dispatch(action)
    }

    /// Prepares for changing the selected store and remains Authenticated.
    ///
    func removeDefaultStore() {
        sessionManager.deleteApplicationPassword()
        ServiceLocator.analytics.refreshUserData()
//        ZendeskProvider.shared.reset()
        ServiceLocator.pushNotesManager.unregisterForRemoteNotifications()
    }

    /// Fully deauthenticates the user, if needed.
    ///
    /// This handles the scenario where `DefaultStoresManager` can't be initialized
    /// in an authenticated state, but the default store is unexpectedly still set.
    ///
    func fullyDeauthenticateIfNeeded() {
        guard !isLoggedIn && !needsDefaultStore else {
            return
        }

        deauthenticate()
    }

    /// Switches the state to a Deauthenticated one.
    ///
    @discardableResult
    func deauthenticate() -> StoresManager {
        applicationPasswordGenerationFailureObserver = nil

//        let resetAction = CardPresentPaymentAction.reset
//        dispatch(resetAction)
//
        state = DeauthenticatedState()
//
        sessionManager.reset()
        ServiceLocator.analytics.refreshUserData()
//        ZendeskProvider.shared.reset()
        ServiceLocator.storageManager.reset()
//        ServiceLocator.productImageUploader.reset()
//
//        updateAndReloadWidgetInformation(with: nil)

        NotificationCenter.default.post(name: .logOutEventReceived, object: nil)
        


        return self
    }

    /// Updates the Default Store as specified.
    /// After this call, `siteID` is updated while `site` might still be nil when it is a newly connected site.
    /// In the case of a newly connected site, it synchronizes the site asynchronously and `site` observable is updated.
    ///
    func updateDefaultStore(storeID: Int64) {
//        sessionManager.defaultStoreID = storeID
        // Because `defaultSite` is loaded or synced asynchronously, it is reset here so that any UI that calls this does not show outdated data.
        // For example, `sessionManager.defaultSite` is used to show site name in various screens in the app.
//        sessionManager.defaultSite = nil
        defaults[.storePhoneNumber] = nil
        defaults[.completedAllStoreOnboardingTasks] = nil
        defaults[.shouldHideStoreOnboardingTaskList] = nil
        defaults[.usedProductDescriptionAI] = nil
        defaults[.hasDismissedWriteWithAITooltip] = nil
        defaults[.numberOfTimesWriteWithAITooltipIsShown] = nil
//        restoreSessionSiteIfPossible()
        ServiceLocator.pushNotesManager.reloadBadgeCount()

//        NotificationCenter.default.post(name: .StoresManagerDidUpdateDefaultSite, object: nil)
    }

    /// Updates the default site only in cases where a site's properties are updated (e.g. after installing & activating Jetpack-the-plugin).
    ///
//    func updateDefaultStore(_ site: Site) {
//        guard site.siteID == sessionManager.defaultStoreID else {
//            return
//        }
//        sessionManager.defaultSite = site
//    }

    /// Updates the user roles for the default Store site.
    ///
//    func updateDefaultRoles(_ roles: [User.Role]) {
//        sessionManager.defaultRoles = roles
//    }
}


// MARK: - Private Methods
//
private extension DefaultStoresManager {

    /// Loads the Default Account into the current Session, if possible.
    ///
    func restoreSessionAccountIfPossible() {
        guard let accountID = sessionManager.defaultAccountID else {
            return
        }

        restoreSessionAccount(with: accountID)
    }
    
    ///
    func restoreSessionAccount(with accountID: Int64) {
        let action = AccountAction.synchronizeAccount() { [weak self] result in
            guard let self else {
                return
            }
            switch result {
            case .success(let account):
                self.replaceTempCredentialsIfNecessary(account: account)
                self.sessionManager.defaultAccount = account
            case .failure(let err):
                print(err.localizedDescription)
            }
        }

        dispatch(action)
    }
    
    /// Synchronizes the WordPress.com Account, associated with the current credentials.

    func synchronizeAccount(onCompletion: @escaping (Result<Void, Error>) -> Void) {
        let action = AccountAction.synchronizeAccount { [weak self] result in
            switch result {
            case .success(let account):
                if let self = self, self.isAuthenticated {
                    self.sessionManager.defaultAccount = account
                    
                    ServiceLocator.analytics.refreshUserData()
                }
                onCompletion(.success(()))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }

        dispatch(action)
    }
    
    

    /// Synchronizes the WordPress.com Account Settings, associated with the current credentials.
    ///
//    func synchronizeAccountSettings(onCompletion: @escaping (Result<Void, Error>) -> Void) {
//        guard let userID = sessionManager.defaultAccount?.userID else {
//            onCompletion(.failure(StoresManagerError.missingDefaultSite))
//            return
//        }
//
//        let action = AccountAction.synchronizeAccountSettings(userID: userID) { [weak self] result in
//            switch result {
//            case .success(let accountSettings):
//                if let self = self, self.isAuthenticated {
//                    // Save the user's preference
//                    ServiceLocator.analytics.setUserHasOptedOut(accountSettings.tracksOptOut)
//                }
//                onCompletion(.success(()))
//            case .failure(let error):
//                onCompletion(.failure(error))
//            }
//        }
//
//        dispatch(action)
//    }
    
    /// Replaces the temporary UUID username in default credentials with the
    /// actual username from the passed account.  This *shouldn't* be necessary
    /// under normal conditions but is a safety net in case there is an error
    /// preventing the temp username from being updated during login.
    ///
    func replaceTempCredentialsIfNecessary(account: Account) {
        guard
            let credentials = sessionManager.defaultCredentials,
            case let .wpcom(_, authToken, siteAddress) = credentials, // Only WPCOM creds have placeholder `username`. WPOrg creds have user entered `username`
            credentials.hasPlaceholderUsername() else {
            return
        }
        authenticate(credentials: .wpcom(username: account.email, authToken: authToken, siteAddress: siteAddress))
    }
}


// MARK: - StoresManagerState
//
protocol StoresManagerState {

    /// Executed before the state is deactivated.
    ///
    func willLeave()

    /// Executed whenever the State is activated.
    ///
    func didEnter()

    /// Executed whenever an Action is received.
    ///
    func onAction(_ action: Action)
}


// MARK: - StoresManagerError
//
enum StoresManagerError: Error {
    case missingDefaultSite
}
