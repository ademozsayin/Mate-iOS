//
//  SessionManager.swift
//  Mate
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Combine
import Foundation
import FiableRedux
import KeychainAccess
import MateNetworking
import class Kingfisher.ImageCache

// MARK: - SessionManager Notifications
//
extension NSNotification.Name {

    /// Posted whenever the Default Account is updated.
    ///
    public static let defaultAccountWasUpdated = Foundation.Notification.Name(rawValue: "DefaultAccountWasUpdated")

    /// Posted after a Log out event happens.
    ///
    public static let logOutEventReceived = Foundation.Notification.Name(rawValue: "LogOutEventReceived")

    /// Posted whenever the app is about to terminate.
    ///
    public static let applicationTerminating = Foundation.Notification.Name(rawValue: "ApplicationTerminating")
}

private extension UserDefaults {
    @objc dynamic var defaultStoreID: Int {
        integer(forKey: Key.defaultStoreID.rawValue)
    }
}

/// SessionManager provides persistent storage for Session-Y Properties.
///
final class SessionManager: SessionManagerProtocol {

    /// Standard Session Manager
    ///
    static var standard: SessionManager {
        return SessionManager(defaults: .standard, keychainServiceName: FiableConstants.keychainServiceName)
    }

    /// Reference to the UserDefaults Instance that should be used.
    ///
    private let defaults: UserDefaults

    /// KeychainAccess Wrapper.
    ///
    private let keychain: Keychain

    /// Cache which stores product images
    ///
    private let imageCache: ImageCache

    /// Default Credentials.
    ///
    var defaultCredentials: Credentials? {
        get {
            return loadCredentials()
        }
        set {
            guard newValue != defaultCredentials else {
                return
            }

            removeCredentials()

            guard let credentials = newValue else {
                return
            }

            saveCredentials(credentials)
        }
    }

    /// Ephemeral: Default Account.
    ///
    var defaultAccount: FiableRedux.Account? {
        didSet {
            defaults[.defaultAccountID] = defaultAccount?.userID
            NotificationCenter.default.post(name: .defaultAccountWasUpdated, object: defaultAccount)
        }
    }

    /// Default AccountID: Returns the last known Account's User ID.
    ///
    var defaultAccountID: Int64? {
        return defaults[.defaultAccountID]
    }


    var defaultStoreIDPublisher: AnyPublisher<Int64?, Never> {
        defaultStoreIDSubject.eraseToAnyPublisher()
    }

    private let defaultStoreIDSubject: CurrentValueSubject<Int64?, Never>

    /// Default Store Site
    ///
//    @Published var defaultSite: Site?

    /// Designated Initializer.
    ///
    init(defaults: UserDefaults,
         keychainServiceName: String,
         imageCache: ImageCache = ImageCache.default) {
        self.defaults = defaults
        self.keychain = Keychain(service: keychainServiceName).accessibility(.afterFirstUnlock)
        self.imageCache = imageCache

        defaultStoreIDSubject = .init(defaults[.defaultStoreID])
    }

    /// Nukes all of the known Session's properties.
    ///
    func reset() {
        deleteApplicationPassword()
        defaultAccount = nil
        defaultCredentials = nil
//        defaultStoreID = nil
//        defaultStoreUUID = nil
//        defaultSite = nil
        defaults[.storePhoneNumber] = nil
        defaults[.completedAllStoreOnboardingTasks] = nil
        defaults[.shouldHideStoreOnboardingTaskList] = nil
        defaults[.hasSavedPrivacyBannerSettings] = nil
        defaults[.usedProductDescriptionAI] = nil
        defaults[.hasDismissedWriteWithAITooltip] = nil
        defaults[.numberOfTimesWriteWithAITooltipIsShown] = nil
        defaults[.storeProfilerAnswers] = nil
        defaults[.aiPromptTone] = nil
        defaults[.hasDismissedBlazeSectionOnMyStore] = nil
        defaults[.numberOfTimesProductCreationAISurveySuggested] = nil
        defaults[.didStartProductCreationAISurvey] = nil
        defaults[.themesPendingInstall] = nil
        defaults[.siteIDPendingStoreSwitch] = nil
        defaults[.expectedStoreNamePendingStoreSwitch] = nil
        imageCache.clearCache()
    }

    /// Deletes application password
    ///
    func deleteApplicationPassword() {
        let useCase: ApplicationPasswordUseCase? = {
            switch loadCredentials() {
            case let .wporg(username, password, siteAddress):
                return try? DefaultApplicationPasswordUseCase(username: username,
                                                              password: password,
                                                              siteAddress: siteAddress,
                                                              keychain: keychain)
            default:
                return nil
            }
        }()
        guard let useCase else {
            return
        }

        Task {
            try await useCase.deletePassword()
        }
    }
}


// MARK: - Private Methods
//
private extension SessionManager {
    enum AuthenticationTypeIdentifier: String {
        case wpcom = "AuthenticationType.wpcom"
        case wporg = "AuthenticationType.wporg"

        init(type: Credentials) {
            switch type {
            case .wpcom:
                self = AuthenticationTypeIdentifier.wpcom
            case .wporg:
                self = AuthenticationTypeIdentifier.wporg
            }
        }
    }

    /// Returns the Default Credentials, if any.
    ///
    func loadCredentials() -> Credentials? {
        guard let username = defaults[.defaultUsername] as? String,
              let secret = keychain[username],
              let siteAddress = defaults[.defaultSiteAddress] as? String else {
            return nil
        }

        // To cover the case of previous versions which don't have the credential type stored in user defaults
        guard let defaultCredentialsType = defaults[.defaultCredentialsType] as? String else {
            return .wpcom(username: username, authToken: secret, siteAddress: siteAddress)
        }

        guard let identifier = AuthenticationTypeIdentifier(rawValue: defaultCredentialsType) else {
            return nil
        }

        switch identifier {
        case .wpcom:
            return .wpcom(username: username, authToken: secret, siteAddress: siteAddress)
        case .wporg:
            return .wporg(username: username, password: secret, siteAddress: siteAddress)
        }
    }

    /// Persists the Credentials's authToken in the keychain, and username in User Settings.
    ///
    func saveCredentials(_ credentials: Credentials) {
        defaults[.defaultUsername] = credentials.username
        defaults[.defaultSiteAddress] = credentials.siteAddress
        defaults[.defaultCredentialsType] = AuthenticationTypeIdentifier(type: credentials).rawValue
        keychain[credentials.username] = credentials.secret
    }

    /// Nukes both, the AuthToken and Default Username.
    ///
    func removeCredentials() {
        guard let username = defaults[.defaultUsername] as? String else {
            return
        }

        keychain[username] = nil
        defaults[.defaultUsername] = nil
        defaults[.defaultCredentialsType] = nil
    }
}
