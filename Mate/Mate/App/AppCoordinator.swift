//
//  AppCoordinator.swift
//  Mate
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Foundation
import UIKit
import Combine
import FiableRedux
import MateStorage
import FiableAuthenticator

class AppNavigator {
    weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
}


final class AppCoordinator {
    let tabBarController: MainTabBarController
    private let window: UIWindow

    private let stores: StoresManager
    private let storageManager: StorageManagerType
    private var authenticationManager: Authentication

    private let loggedOutAppSettings: LoggedOutAppSettingsProtocol

    private var authStatesSubscription: AnyCancellable?
    private var localNotificationResponsesSubscription: AnyCancellable?
    private var isLoggedIn: Bool = false


    /// Checks on whether the Apple ID credential is valid when the app is logged in and becomes active.
    ///
//    private lazy var appleIDCredentialChecker = AppleIDCredentialChecker()

    init(window: UIWindow,
         stores: StoresManager = ServiceLocator.stores,
         loggedOutAppSettings: LoggedOutAppSettingsProtocol = LoggedOutAppSettings(userDefaults: .standard),
         storageManager: StorageManagerType = ServiceLocator.storageManager,
         authenticationManager: Authentication = ServiceLocator.authenticationManager
     
    ) {
        self.window = window
        self.tabBarController = {
            let storyboard = UIStoryboard(name: "Main", bundle: nil) // Main is the name of storyboard
            guard let tabBarController = storyboard.instantiateInitialViewController() as? MainTabBarController else {
                fatalError("Cannot load main tab bar controller from Storyboard")
            }
            return tabBarController
        }()
        
        self.stores = stores
        self.loggedOutAppSettings = loggedOutAppSettings
        self.storageManager = storageManager
        self.authenticationManager = authenticationManager

        // Configures authenticator first in case `WordPressAuthenticator` is used in other `AppDelegate` launch events.
        configureAuthenticator()
        
    }

    func start() {
        authStatesSubscription = stores.isLoggedInPublisher
        .sink { isLoggedIn in
            // Handle the isLoggedIn value here
            switch isLoggedIn {
            case true:
                print("asdasd")
                self.configureAuthenticator()
                self.displayLoggedInUI()
//                self.synchronizeAndShowWhatsNew()
//                self.checkPendingStoreCreation()
            case false:
                self.displayAuthenticatorWithOnboardingIfNeeded()
            }
            self.isLoggedIn = isLoggedIn
        }
    }
}

private extension AppCoordinator {

  
    /// Displays the WordPress.com Authentication UI.
    ///
    func displayAuthenticatorWithOnboardingIfNeeded() {
        if canPresentLoginOnboarding() {
            // Sets a placeholder view controller as the window's root view as it is required
            // at the end of app launch.
            setWindowRootViewControllerAndAnimateIfNeeded(.init())
            presentLoginOnboarding { [weak self] in
                guard let  self else { return }
                // Only displays the authenticator when dismissing onboarding to allow time for A/B test setup.
                self.configureAndDisplayAuthenticator()
                print("xxx")
            }
        } else {
            print("aaa")
            configureAndDisplayAuthenticator()
        }
    }
    
    /// Configures the WPAuthenticator and sets the authenticator UI as the window's root view.
    func configureAndDisplayAuthenticator() {
        configureAuthenticator()
        displayAuthenticator()
    }

    /// Configures the WPAuthenticator for usage in both logged-in and logged-out states.
    func configureAuthenticator() {
        authenticationManager.initialize()
        authenticationManager.setLoggedOutAppSettings(loggedOutAppSettings)
        authenticationManager.displayAuthenticatorIfLoggedOut = { [weak self] in
            guard let self, self.isLoggedIn == false else { return nil }
            guard let loginNavigationController = self.window.rootViewController as? LoginNavigationController else {
                return self.displayAuthenticator() as? LoginNavigationController
            }
            return loginNavigationController
        }
    }
    
    

    @discardableResult
    func displayAuthenticator() -> UIViewController {
        let authenticationUI = authenticationManager.authenticationUI()
        setWindowRootViewControllerAndAnimateIfNeeded(authenticationUI) { [weak self] _ in
            guard let self = self else { return }
            self.tabBarController.removeViewControllers()
        }
        return authenticationUI
    }
    
    
    /// Determines whether the login onboarding should be shown.
    func canPresentLoginOnboarding() -> Bool {
        // Since we cannot control the user defaults in the simulator where UI tests are run on,
        // login onboarding is not shown in UI tests for now.
        // If we want to add UI tests for the login onboarding, we can add another launch argument
        // so that we can show/hide the onboarding screen consistently.
        let isUITesting: Bool = CommandLine.arguments.contains("-ui_testing")
        guard isUITesting == false else {
            return false
        }

        return loggedOutAppSettings.hasFinishedOnboarding == false
    }
    
    /// Displays logged in tab bar UI.
    ///
    func displayLoggedInUI() {
        setWindowRootViewControllerAndAnimateIfNeeded(tabBarController)
    }
    
    // If the app is authenticated but there is no default store ID on launch,
    /// check for errors and display store picker if none exists.
    ///
//    func displayLoggedInStateWithoutDefaultStore() {
//        // Store picker is only displayed by `AppCoordinator` on launch, when the window's root is uninitialized.
//        // In other cases when the app is authenticated but there is no default store ID, the store picker is shown by authentication UI.
//        guard window.rootViewController == nil else {
//            return
//        }
//
//        /// If authenticating with site credentials only is incomplete,
//        /// show the prologue screen to force the user to log in again.
//        guard stores.isAuthenticatedWithoutWPCom == false else {
//            return displayAuthenticatorWithOnboardingIfNeeded()
//        }
//        configureAuthenticator()
//
//        let matcher = ULAccountMatcher(storageManager: storageManager)
//        matcher.refreshStoredSites()
//
//        // Show error for the current site URL if exists.
//        if let siteURL = loggedOutAppSettings.errorLoginSiteAddress {
//            if let authenticationUI = authenticationManager.authenticationUI() as? UINavigationController,
//               let errorController = authenticationManager.errorViewController(for: siteURL,
//                                                                               with: matcher,
//                                                                               credentials: nil,
//                                                                               navigationController: authenticationUI,
//                                                                               onStorePickerDismiss: {}) {
//                window.rootViewController = authenticationUI
//                // don't let user navigate back to the login screen unless they tap log out.
//                errorController.navigationItem.hidesBackButton = true
//                authenticationUI.show(errorController, sender: nil)
//                return
//            }
//        }
//
//        // All good, show store picker
//        let navigationController = OnsaNavigationController()
//        setWindowRootViewControllerAndAnimateIfNeeded(navigationController)
//        DDLogInfo("💬 Authenticated user does not have a Woo store selected — launching store picker.")
//        storePickerCoordinator = StorePickerCoordinator(navigationController, config: .standard)
//        storePickerCoordinator?.start()
//        storePickerCoordinator?.onDismiss = { [weak self] in
//            guard let self = self else { return }
//            if self.isLoggedIn == false {
//                self.displayAuthenticatorWithOnboardingIfNeeded()
//            }
//        }
//    }
    
    /// Presents onboarding on top of the authentication UI under certain criteria.
    /// - Parameter onDismiss: invoked when the onboarding is dismissed.
    func presentLoginOnboarding(onDismiss: @escaping () -> Void) {
        let onboardingViewController = LoginOnboardingViewController { [weak self] action in
            guard let self = self else { return }
            onDismiss()
            self.loggedOutAppSettings.setHasFinishedOnboarding(true)
            self.window.rootViewController?.dismiss(animated: true)

        }
        onboardingViewController.modalPresentationStyle = .fullScreen
        onboardingViewController.modalTransitionStyle = .crossDissolve
        window.rootViewController?.present(onboardingViewController, animated: false)

//        analytics.track(event: .LoginOnboarding.loginOnboardingShown())
    }
    
}

private extension AppCoordinator {
    /// Sets the app window's root view controller, with animation only if the root view controller is previously non-nil.
    /// - Parameters:
    ///   - rootViewController: view controller to be set as the window's root view controller.
    ///   - onCompletion: called after the root view controller is set after animation if needed.
    ///                   The boolean value indicates whether or not the animations actually finished before the completion handler was called.
    func setWindowRootViewControllerAndAnimateIfNeeded(_ rootViewController: UIViewController, onCompletion: @escaping (Bool) -> Void = { _ in }) {
        // Animates window transition only if the root view controller is non-nil originally.
        let shouldAnimate = window.rootViewController != nil
        window.rootViewController = rootViewController
        if shouldAnimate {
            UIView.transition(with: window, duration: Constants.animationDuration, options: .transitionCrossDissolve, animations: {}, completion: onCompletion)
        } else {
            onCompletion(false)
        }
    }
}



private extension AppCoordinator {
    enum Constants {
        static let animationDuration = TimeInterval(0.3)
    }

    enum Localization {
        enum StoreReadyAlert {
            static let title = NSLocalizedString("appCoordinator.storeReadyAlert.title",
                                                 value: "Your new store is ready.",
                                                 comment: "Title of the alert to ask confirmation to switch to the newly created store.")
            static let message = NSLocalizedString("appCoordinator.storeReadyAlert.message",
                                                   value: "Do you want to start managing it now?",
                                                   comment: "Message of the alert to ask confirmation to switch to the newly created store.")
            static let switchStoreButton = NSLocalizedString("appCoordinator.storeReadyAlert.switchStoreButton",
                                                             value: "Switch Store",
                                                             comment: "Button to switch to the new store.")
            static let cancelButton = NSLocalizedString("appCoordinator.storeReadyAlert.cancelButton",
                                                        value: "Cancel",
                                                        comment: "Button to dismiss the alert asking for confirmation to switch store.")
        }
    }
}
