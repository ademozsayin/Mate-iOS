//
//  AppDelegate.swift
//  Mate
//
//  Created by Adem Özsayın on 26.02.2024.
//

import UIKit
import CoreData
import MateNetworking
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate  {
    
    /// AppDelegate's Instance
    ///
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    /// Main Window
    ///
    var window: UIWindow?

    /// Coordinates app navigation based on authentication state.
    ///
    private var appCoordinator: AppCoordinator?

    /// Tab Bar Controller
    ///
    var tabBarController: MainTabBarController? {
        appCoordinator?.tabBarController
    }

    private var universalLinkRouter: UniversalLinkRouter?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        print(BuildConfiguration.current)
       
        setupCocoaLumberjack()

        setupLogLevel(.verbose)
       
        setupPushNotificationsManagerIfPossible()
        setupAppRatingManager()
        setupUserNotificationCenter()
        
        if let path = getSQLitePath() {
            print("SQLite database path: \(path)")
        } else {
            print("SQLite database not found.")
        }
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
       
        setupMainWindow()
        setupComponentsAppearance()
        setupUniversalLinkRouter()
        appCoordinator?.start()
        
//        ServiceLocator.analytics.track(.applicationOpened, withProperties: [:])

        return true
    }
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        guard let rootViewController = window?.rootViewController else {
            fatalError()
        }
//        if ServiceLocator.stores.isAuthenticatedWithoutWPCom,
//           let site = ServiceLocator.stores.sessionManager.defaultSite {
//            let coordinator = JetpackSetupCoordinator(site: site, rootViewController: rootViewController)
//            jetpackSetupCoordinator = coordinator
//            return coordinator.handleAuthenticationUrl(url)
//        }
        return ServiceLocator.authenticationManager.handleAuthenticationUrl(url, options: options, rootViewController: rootViewController)
    }
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            handleWebActivity(userActivity)
        }

        SpotlightManager.handleUserActivity(userActivity)
        return true
    }

    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Mate")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

private extension AppDelegate {
    func setupMainWindow() {
        let window = UIWindow()
        window.makeKeyAndVisible()
        self.window = window
        appCoordinator = AppCoordinator(window: window)
    }
    
    /// Push Notifications: Authorization + Registration!
    ///
    func setupPushNotificationsManagerIfPossible() {
        let stores = ServiceLocator.stores
        guard stores.isAuthenticated,
              stores.isAuthenticatedWithoutWPCom == false else {
            if ServiceLocator.featureFlagService.isFeatureFlagEnabled(.storeCreationNotifications) {
                ServiceLocator.pushNotesManager.ensureAuthorizationIsRequested(includesProvisionalAuth: true, onCompletion: nil)
            }
            return
        }

        #if targetEnvironment(simulator)
            DDLogVerbose("👀 Push Notifications are not supported in the Simulator!")
        #else
            let pushNotesManager = ServiceLocator.pushNotesManager
            pushNotesManager.registerForRemoteNotifications()
            pushNotesManager.ensureAuthorizationIsRequested(includesProvisionalAuth: false, onCompletion: nil)
        #endif
    }

    func setupUserNotificationCenter() {
        guard ServiceLocator.featureFlagService.isFeatureFlagEnabled(.storeCreationNotifications) else {
            return
        }
        UNUserNotificationCenter.current().delegate = self
    }
       
    func setupUniversalLinkRouter() {
        guard let tabBarController = tabBarController else { return }
        universalLinkRouter = UniversalLinkRouter.defaultUniversalLinkRouter(tabBarController: tabBarController)
    }
    
    /// Set up app review prompt
    func setupAppRatingManager() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            DDLogError("No CFBundleShortVersionString found in Info.plist")
            return
        }

        let appRating = AppRatingManager.shared
        appRating.register(section: "notifications", significantEventCount: FiableConstants.notificationEventCount)
        appRating.systemWideSignificantEventCountRequiredForPrompt = FiableConstants.systemEventCount
        appRating.setVersion(version)
    }

    
    func disableAnimationsIfNeeded() {
        guard ProcessConfiguration.shouldDisableAnimations else {
            return
        }

        UIView.setAnimationsEnabled(false)
        /// Trick found at: https://twitter.com/twannl/status/1232966604142653446
        UIApplication
            .shared
            .connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .forEach {
                $0.layer.speed = 100
            }
    }
}

// MARK: - Minimum Version
//
private extension AppDelegate {

    func checkForUpgrades() {
        let currentVersion = UserAgent.bundleShortVersion
        let versionOfLastRun = UserDefaults.standard[.versionOfLastRun] as? String
        if versionOfLastRun == nil {
            // First run after a fresh install
//            ServiceLocator.analytics.track(.applicationInstalled,
//                                           withProperties: ["after_abtest_setup": true])
            UserDefaults.standard[.installationDate] = Date()
        } else if versionOfLastRun != currentVersion {
            // App was upgraded
//            ServiceLocator.analytics.track(.applicationUpgraded, withProperties: ["previous_version": versionOfLastRun ?? String()])
        }

        UserDefaults.standard[.versionOfLastRun] = currentVersion
    }
}

// MARK: - Authentication Methods
//
extension AppDelegate {
    /// Whenever we're in an Authenticated state, let's Sync all of the WC-Y entities.
    ///
    private func synchronizeEntitiesIfPossible() {
        guard ServiceLocator.stores.isAuthenticated else {
            return
        }

        ServiceLocator.stores.synchronizeEntities(onCompletion: nil)
    }

    /// De-authenticates the user upon application password generation failure or WPCOM token expiry.
    ///
    private func listenToAuthenticationFailureNotifications() {
        let stores = ServiceLocator.stores
        if stores.isAuthenticatedWithoutWPCom {
            stores.listenToApplicationPasswordGenerationFailureNotification()
        } else {
            stores.listenToWPCOMInvalidWPCOMTokenNotification()
        }
    }

    /// Runs whenever the Authentication Flow is completed successfully.
    ///
    func authenticatorWasDismissed() {
        setupPushNotificationsManagerIfPossible()
//        requirementsChecker.checkEligibilityForDefaultStore()
    }
}

// MARK: - Firebase

extension AppDelegate: MessagingDelegate {
    func messaging(
        _: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        let tokenDict = ["token": fcmToken ?? ""]
        // This token can be used for testing notifications on FCM
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict
        )
        
        guard let userID = ServiceLocator.stores.sessionManager.defaultAccountID else {
            return
        }
        
        ServiceLocator.pushNotesManager.registerDeviceToken(with: nil, userId: Int(userID), fcmToken: fcmToken)

    }
}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let userID = ServiceLocator.stores.sessionManager.defaultAccountID else {
            return
        }

//        #if DEBUG
//            Messaging.messaging().setAPNSToken(deviceToken, type: .sandbox)
//        #else
//            Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
//        #endif

        //TODO: - TEST IT FOR DB
      
        Messaging.messaging().setAPNSToken(deviceToken, type: .prod)
        // Moved to MessagingDelegate
//        ServiceLocator.pushNotesManager.registerDeviceToken(with: deviceToken, userId: Int(userID))
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        ServiceLocator.pushNotesManager.registrationDidFail(with: error)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        await ServiceLocator.pushNotesManager.handleUserResponseToNotification(response)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        await ServiceLocator.pushNotesManager.handleNotificationInTheForeground(notification)
    }
}

// MARK: - Universal Links

private extension AppDelegate {
    func handleWebActivity(_ activity: NSUserActivity) {
        guard let linkURL = activity.webpageURL else {
            return
        }

        universalLinkRouter?.handle(url: linkURL)
    }
}
