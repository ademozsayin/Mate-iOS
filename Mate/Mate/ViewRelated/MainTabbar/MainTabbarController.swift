//
//  MainTabbarController.swift
//  Mate
//
//  Created by Adem Özsayın on 21.03.2024.
//

import Combine
import UIKit
import FiableRedux
import FiableUI


/// Enum representing the individual tabs
///
enum WooTab {
    
    case map
    /// My Store Tab
    ///
//    case myStore
    
    //    /// Orders Tab
    //    ///
    //    case orders
    //
        /// Products Tab
        ///
    case products
    
    /// Hub Menu Tab
    ///
    case hubMenu
}

extension WooTab {
    /// Initializes a tab with the visible tab index.
    ///
    /// - Parameters:
    ///   - visibleIndex: the index of visible tabs on the tab bar
    init(visibleIndex: Int) {
        let tabs = WooTab.visibleTabs()
        self = tabs[visibleIndex]
    }
    
    /// Returns the visible tab index.
    func visibleIndex() -> Int {
        let tabs = WooTab.visibleTabs()
        guard let tabIndex = tabs.firstIndex(where: { $0 == self }) else {
            assertionFailure("Trying to get the visible tab index for tab \(self) while the visible tabs are: \(tabs)")
            return 0
        }
        return tabIndex
    }
    
    // Note: currently only the Dashboard tab (My Store) view controller is set up in Main.storyboard.
    private static func visibleTabs() -> [WooTab] {
        [.map, .products,.hubMenu]
        //        [.myStore, .orders, .products, .hubMenu]
    }
}


// MARK: - MainTabBarController

/// A view controller that shows the tabs Store, Orders, Products, and Reviews.
///
/// TODO Migrate the `viewControllers` management from `Main.storyboard` to here (as code).
///
final class MainTabBarController: UITabBarController {
    
    /// For picking up the child view controller's status bar styling
    /// - returns: nil to let the tab bar control styling or `children.first` for VC control.
    ///
    public override var childForStatusBarStyle: UIViewController? {
        return nil
    }
    
    /// Used for overriding the status bar style for all child view controllers
    ///
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    /// ViewModel
    ///
    private let viewModel = MainTabViewModel()
    
    /// Tab view controllers
    ///
    private let dashboardNavigationController = OnsaTabNavigationController()
    private let ordersContainerController = TabContainerController()
    
    private let eventsContainerController = TabContainerController()
    
    /// Unfortunately, we can't use the above container to directly hold a WooTabNavigationController, due to
    /// a longstanding bug where a black bar equal to the tab bar height is shown when a nav controller
    /// is shown as an embedded vc in a tab. See link for details, but the solutions don't work here.
    /// https://stackoverflow.com/questions/28608817/uinavigationcontroller-embedded-in-a-container-view-displays-a-table-view-contr
    /// remove when .splitViewInProductsTab is removed.
    private let eventsNavigationController = OnsaTabNavigationController()
    
    private let reviewsNavigationController = OnsaTabNavigationController()
    private let hubMenuNavigationController = OnsaTabNavigationController()
    private var hubMenuTabCoordinator: HubMenuCoordinator?
    private var mapTabCoordinator: MapCoordinator?
    private let mapNavigationController = OnsaTabNavigationController()
    private var cancellableSiteID: AnyCancellable?
    private let featureFlagService: FeatureFlagService
    private let noticePresenter: NoticePresenter
    private let stores: StoresManager = ServiceLocator.stores
    private let analytics: MateAnalytics
    
    private var productImageUploadErrorsSubscription: AnyCancellable?
    
    private lazy var isProductsSplitViewFeatureFlagOn = featureFlagService.isFeatureFlagEnabled(.splitViewInProductsTab)
    
    
    init(featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService,
         noticePresenter: NoticePresenter = ServiceLocator.noticePresenter,
         analytics: MateAnalytics = ServiceLocator.analytics) {
        
        // Initialize your custom properties first
        self.featureFlagService = featureFlagService
        self.noticePresenter = noticePresenter
        self.analytics = analytics
        
        // Call the designated initializer of the superclass
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        self.featureFlagService = ServiceLocator.featureFlagService
        self.noticePresenter = ServiceLocator.noticePresenter
        self.analytics = ServiceLocator.analytics
        super.init(coder: coder)
    }

        
    deinit {
        cancellableSiteID?.cancel()
    }
    
    // MARK: - Overridden Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate() // call this to refresh status bar changes happening at runtime
        
        configureTabViewControllers()
        observeSiteIDForViewControllers()
        viewModel.loadHubMenuTabBadge()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Note:
        /// We hook up KVO in this spot... because at the point in which `viewDidLoad` fires, we haven't really fully
        /// loaded the childViewControllers, and the tabBar isn't fully initialized.
        ///
        
        //        startListeningToOrdersBadge()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewModel.onViewDidAppear()
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let currentlySelectedTab = WooTab(visibleIndex: selectedIndex)
        guard let userSelectedIndex = tabBar.items?.firstIndex(of: item) else {
            return
        }
        let userSelectedTab = WooTab(visibleIndex: userSelectedIndex)
        
        // Did we reselect the already-selected tab?
        if currentlySelectedTab == userSelectedTab {
            trackTabReselected(tab: userSelectedTab)
            scrollContentToTop()
        } else {
            trackTabSelected(newTab: userSelectedTab)
        }
    }
    
    // MARK: - Public Methods
    
    /// Switches the TabBarController to the specified Tab
    ///
    func navigateTo(_ tab: WooTab, animated: Bool = false, completion: (() -> Void)? = nil) {
        navigateToTabWithViewController(tab, animated: animated) { _ in
            completion?()
        }
    }
    
    /// Switches the TabBarController to the specified tab and pops to root of the tab if the root is a `UINavigationController`.
    ///
    /// - Parameters:
    ///   - tab: The tab to switch to.
    ///   - animated: Whether the tab switch is animated.
    ///   - completion: Invoked when switching to the tab's root screen is complete with the root view controller.
    func navigateToTabWithViewController(_ tab: WooTab, animated: Bool = false, completion: ((UIViewController) -> Void)? = nil) {
        dismiss(animated: animated) { [weak self] in
            guard let self else { return }
            selectedIndex = tab.visibleIndex()
            guard let selectedViewController else {
                return
            }
            if let navController = selectedViewController as? UINavigationController {
                navController.popToRootViewController(animated: animated) {
                    completion?(navController)
                }
            } else {
                completion?(selectedViewController)
            }
        }
    }
    
    /// Removes the view controllers in each tab's navigation controller, and resets any logged in properties.
    /// Called after the app is logged out and authentication UI is presented.
    func removeViewControllers() {
        
        hubMenuTabCoordinator = nil
        mapTabCoordinator = nil
        mapNavigationController.viewControllers = []
        hubMenuNavigationController.viewControllers = []
        
        viewControllers?.compactMap { $0 as? UINavigationController }.forEach { navigationController in
            navigationController.viewControllers = []
        }
       
    }
}


// MARK: - UIViewControllerTransitioningDelegate
//
extension MainTabBarController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        guard presented is FancyAlertViewController else {
            return nil
        }
        
        return FancyAlertPresentationController(presentedViewController: presented, presenting: presenting)
    }
}


// MARK: - Static navigation helpers
//
private extension MainTabBarController {
    
    /// *When applicable* this method will scroll the visible content to top.
    ///
    func scrollContentToTop() {
        guard let navController = selectedViewController as? UINavigationController else {
            return
        }
        
        navController.scrollContentToTop(animated: true)
    }
    
    /// Tracks "Tab Selected" Events.
    ///
    func trackTabSelected(newTab: WooTab) {
        //        switch newTab {
        //        case .myStore:
        //            ServiceLocator.analytics.track(.dashboardSelected)
        //        case .orders:
        //            ServiceLocator.analytics.track(
        //                event: .Orders.ordersSelected(horizontalSizeClass: UITraitCollection.current.horizontalSizeClass))
        //        case .products:
        //            ServiceLocator.analytics.track(
        //                event: .Products.productListSelected(horizontalSizeClass: UITraitCollection.current.horizontalSizeClass))
        //        case .hubMenu:
        //            ServiceLocator.analytics.track(.hubMenuTabSelected)
        //            break
        //        }
    }
    
    /// Tracks "Tab Re Selected" Events.
    ///
    func trackTabReselected(tab: WooTab) {
        //        switch tab {
        //        case .myStore:
        //            ServiceLocator.analytics.track(.dashboardReselected)
        //        case .orders:
        //            ServiceLocator.analytics.track(
        //                event: .Orders.ordersReselected(horizontalSizeClass: UITraitCollection.current.horizontalSizeClass))
        //        case .products:
        //            ServiceLocator.analytics.track(
        //                event: .Products.productListReselected(horizontalSizeClass: UITraitCollection.current.horizontalSizeClass))
        //        case .hubMenu:
        //            ServiceLocator.analytics.track(.hubMenuTabReselected)
        //            break
        //        }
    }
}


// MARK: - Static navigation helpers
//
extension MainTabBarController {
    
    /// Switches to the My Store tab and pops to the root view controller
    ///
    static func switchToMyStoreTab(animated: Bool = false) {
//        navigateTo(.myStore, animated: animated)
    }
    
    /// Switches to the Orders tab and pops to the root view controller
    ///
    static func switchToOrdersTab(completion: (() -> Void)? = nil) {
        //        navigateTo(.orders, completion: completion)
    }
    
    /// Switches to the Products tab and pops to the root view controller
    ///
    static func switchToProductsTab(completion: (() -> Void)? = nil) {
        navigateTo(.products, completion: completion)
    }
    
    /// Switches to the Hub Menu tab and pops to the root view controller
    ///
    static func switchToHubMenuTab(completion: (() -> Void)? = nil) {
        navigateTo(.hubMenu, completion: completion)
    }
    
    static func switchToMapTab(completion: (() -> Void)? = nil) {
        navigateTo(.map, completion: completion)
    }
    
    /// Switches the TabBarController to the specified Tab
    ///
    private static func navigateTo(_ tab: WooTab, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let tabBar = AppDelegate.shared.tabBarController else {
            return
        }
        
        tabBar.navigateTo(tab, animated: animated, completion: completion)
    }
    
    /// Returns the "Top Visible Child" of the specified type
    ///
    private static func childViewController<T: UIViewController>() -> T? {
        let selectedViewController = AppDelegate.shared.tabBarController?.selectedViewController
        guard let navController = selectedViewController as? UINavigationController else {
            return selectedViewController as? T
        }
        
        return navController.topViewController as? T
    }
}


// MARK: - Static Navigation + Details!
//
extension MainTabBarController {

    
    /// Syncs the notification given the ID, and handles the notification based on its notification kind.
    ///
    static func presentNotificationDetails(for noteID: Int64) {
        let action = NotificationAction.synchronizeNotification(noteID: noteID) { note, error in
            guard let note = note else {
                return
            }
            let siteID = Int64(note.meta.identifier(forKey: .site) ?? Int.min)

//            showStore(with: siteID, onCompletion: { _ in
                presentNotificationDetails(for: note)
//            })
        }
        ServiceLocator.stores.dispatch(action)
    }

    /// Presents the order details if the `note` is for an order push notification.
    ///
    private static func presentNotificationDetails(for note: Note) {
        switch note.kind {
        case .storeOrder:
            switchToOrdersTab {
//                ordersTabSplitViewWrapper()?.presentDetails(for: note)
            }
        default:
            break
        }

    }


    /// Switches to the hub Menu & Navigates to the Privacy Settings Screen.
    ///
    static func navigateToPrivacySettings() {
        //        switchToHubMenuTab {
        //            guard let hubMenuViewController: HubMenuViewController = childViewController() else {
        //                return DDLogError("⛔️ Could not switch to the Hub Menu")
        //            }
        //            hubMenuViewController.showPrivacySettings()
        //        }
    }
}

// MARK: - DeeplinkForwarder
//
//extension MainTabBarController: DeepLinkNavigator {
//    func navigate(to destination: any DeepLinkDestinationProtocol) {
//        navigateTo(.hubMenu) { [weak self] in
//            self?.hubMenuTabCoordinator?.navigate(to: destination)
//        }
//    }
//}

// MARK: - Site ID observation for updating tab view controllers
//
private extension MainTabBarController {
    func configureTabViewControllers() {
        viewControllers = {
            var controllers = [UIViewController]()
            
            let tabs: [WooTab] = [.map, .products, .hubMenu]
            tabs.forEach { tab in
                let tabIndex = tab.visibleIndex()
                let tabViewController = rootTabViewController(tab: tab)
                controllers.insert(tabViewController, at: tabIndex)
            }
            return controllers
        }()
    }
    
    func rootTabViewController(tab: WooTab) -> UIViewController {
        switch tab {
        case .map:
            return mapNavigationController
            
        case .products:
            return isProductsSplitViewFeatureFlagOn ? eventsContainerController: eventsNavigationController
        
        case .hubMenu:
            return hubMenuNavigationController
//       
//        case .myStore:
//            return dashboardNavigationController
        }
    }
    
    
    func observeSiteIDForViewControllers() {
        self.updateViewControllers()
        cancellableSiteID = stores.isLoggedInPublisher.sink { [weak self] isLoggedIn in
            guard let self = self else {
                return
            }
            
            if isLoggedIn {
                self.updateViewControllers()
            }
        }
    }
    
    func updateViewControllers() {


        // Initialize each tab's root view controller

        if isProductsSplitViewFeatureFlagOn {
            eventsContainerController.wrappedController = EventsSplitViewWrapperController()
        } else {
            eventsNavigationController.viewControllers = [
                EventsViewController(selectedEvent: Empty().eraseToAnyPublisher(),
                                     navigateToContent: { _ in })
            ]
        }

        // Configure hub menu tab coordinator once per logged in session potentially with multiple sites.
        if hubMenuTabCoordinator == nil {
            let hubTabCoordinator = createHubMenuTabCoordinator()
            self.hubMenuTabCoordinator = hubTabCoordinator
            hubTabCoordinator.start()
        }
        
        hubMenuTabCoordinator?.activate(siteID: 1)
        
        if mapTabCoordinator == nil {
            let mapTabCoordinator = createMapTabCoordinator()
            self.mapTabCoordinator = mapTabCoordinator
            mapTabCoordinator.start()
        }
        mapTabCoordinator?.activate()

        
        viewModel.loadHubMenuTabBadge()

        // Set map to be the default tab.
        selectedIndex = WooTab.map.visibleIndex()
    }
    
//    func createDashboardViewController() -> UIViewController {
//        return AViewController()
//    }
    
    
    func createMapTabCoordinator() -> MapCoordinator {
        MapCoordinator(navigationController: mapNavigationController,
                           willPresentReviewDetailsFromPushNotification: { [weak self] in
            await withCheckedContinuation { [weak self] continuation in
                self?.navigateTo(.map) {
                    continuation.resume(returning: ())
                }
            }
        })
    }
    
    
    func createHubMenuTabCoordinator() -> HubMenuCoordinator {
        HubMenuCoordinator(
            navigationController: hubMenuNavigationController,
            willPresentReviewDetailsFromPushNotification: { [weak self] in
            await withCheckedContinuation { [weak self] continuation in
                self?.navigateTo(.hubMenu) {
                    continuation.resume(returning: ())
                }
            }
        })
    }
}

private extension MainTabBarController {
    enum Constants {
        // Used to delay a second navigation after the previous one is called,
        // to ensure that the first transition is finished. Without this delay
        // the second one might not happen.
        static let screenTransitionsDelay = 0.3
    }
}



// MARK: - DeeplinkForwarder
//
extension MainTabBarController: DeepLinkNavigator {
    func navigate(to destination: any DeepLinkDestinationProtocol) {
        navigateTo(.hubMenu) { [weak self] in
            self?.hubMenuTabCoordinator?.navigate(to: destination)
        }
    }
}
