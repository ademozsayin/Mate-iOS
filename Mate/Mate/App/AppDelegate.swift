//
//  AppDelegate.swift
//  Mate
//
//  Created by Adem Özsayın on 26.02.2024.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
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
        setupMainWindow()
        // Setup Components
        setupComponentsAppearance()
        setupCocoaLumberjack()
#if DEBUG
        setupLogLevel(.verbose)

        if let path = getSQLitePath() {
            print("SQLite database path: \(path)")
        } else {
            print("SQLite database not found.")
        }
#endif
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setupUniversalLinkRouter()
        
        appCoordinator?.start()
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
//        trackWidgetTappedIfNeeded(userActivity: userActivity)

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
    
    ///
   
    
    func setupUniversalLinkRouter() {
        guard let tabBarController = tabBarController else { return }
        universalLinkRouter = UniversalLinkRouter.defaultUniversalLinkRouter(tabBarController: tabBarController)
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
