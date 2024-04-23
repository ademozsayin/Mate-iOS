//
//  MainTabViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 22.03.2024.
//

import Foundation
import FiableRedux
import Combine

// MARK: - MainTabViewModel Notifications
//
extension NSNotification.Name {

    /// Posted whenever an OrderBadge refresh is required.
    ///
    public static let ordersBadgeReloadRequired = Foundation.Notification.Name(rawValue: "com.woocommerce.ios.ordersBadgeReloadRequired")

    /// Posted whenever a refresh of Reviews tab is required.
    ///
    public static let reviewsBadgeReloadRequired = Foundation.Notification.Name(rawValue: "com.woocommerce.ios.reviewsBadgeReloadRequired")
}

final class MainTabViewModel {

    private let storesManager: StoresManager

//    private var statusResultsController: ResultsController<StorageOrderStatus>?

    private let featureFlagService: FeatureFlagService

    /// Whether we should show the reviews badge on the hub menu tab.
    /// Even if we set this value to true it might not be shown, as there might be other badge types with more priority
    ///
    @Published private var shouldShowReviewsBadgeOnHubMenuTab: Bool = false

    /// Whether we should show the new feature badge on the hub menu tab.
    /// Even if we set this value to true it might not be shown, as there might be other badge types with more priority
    ///
    @Published private var shouldShowNewFeatureBadgeOnHubMenuTab: Bool = false

    private var cancellables = Set<AnyCancellable>()

//    let tapToPayBadgePromotionChecker: TapToPayBadgePromotionChecker = TapToPayBadgePromotionChecker()

    init(storesManager: StoresManager = ServiceLocator.stores,
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService) {
        self.storesManager = storesManager
        self.featureFlagService = featureFlagService

//        if let siteID = storesManager.sessionManager.defaultStoreID {
//            configureOrdersStatusesListener(for: siteID)
//        }
    }

    /// Setup: ResultsController for `processing` OrderStatus updates
    ///
    func configureOrdersStatusesListener(for siteID: Int64) {
//        statusResultsController = createStatusResultsController(siteID: siteID)
//        configureStatusResultsController()
    }

    /// Callback to be executed when this view model receives new data
    /// passing the string to be presented in the badge as a parameter
    ///
    var onOrdersBadgeReload: ((String?) -> Void)?

    /// Callback to be executed when the menu tab badge needs to be displayed
    /// It provides the badge type
    ///
//    var onMenuBadgeShouldBeDisplayed: ((NotificationBadgeType) -> Void)?

    /// Callback to be executed when the menu tab badge needs to be hidden
    ///
    var onMenuBadgeShouldBeHidden: (() -> ())?

    /// Must be called during `MainTabBarController.viewDidAppear`. This will try and save the
    /// app installation date.
    ///
    func onViewDidAppear() {
        saveInstallationDateIfNecessary()
    }

    /// Bootstrap the data pipeline for the orders badge
    /// Fetches the initial badge count and observes notifications requesting a refresh
    /// The notification observed will be `ordersBadgeReloadRequired`
    ///
    func startObservingOrdersCount() {
        observeBadgeRefreshNotifications()
        updateBadgeFromCache()
    }

    /// Loads the the hub Menu tab badge and listens to any change to update it
    ///
    func loadHubMenuTabBadge() {
        synchronizeShouldShowBadgeOnHubMenuTabLogic()

        listenToReviewsBadgeReloadRequired()
        retrieveShouldShowReviewsBadgeOnHubMenuTabValue()

//        tapToPayBadgePromotionChecker.$shouldShowTapToPayBadges.share().assign(to: &$shouldShowNewFeatureBadgeOnHubMenuTab)
    }
}


private extension MainTabViewModel {

    /// Get last known data from cache (if exists) and draw it on a badge
    ///
    func updateBadgeFromCache() {
//        let initialCachedOrderStatus = statusResultsController?.fetchedObjects.first
//        processBadgeCount(initialCachedOrderStatus)
    }

    /// Trigger network action to update underlying cache. Badge redraw will be triggered by `statusResultsController`
    ///
    @objc func requestBadgeCount() {

    }


    func observeBadgeRefreshNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(requestBadgeCount),
                                               name: .ordersBadgeReloadRequired,
                                               object: nil)
    }

    /// Persists the installation date if it hasn't been done already.
    func saveInstallationDateIfNecessary() {
        // Unfortunately, our `StoresManager` cannot handle actions (e.g. `AppSettingsAction`) if
        // the user is not logged in. That's because the state will be a `DeauthenticatedState`
        // which just ignores all dispatched actions.
        //
        // So, for now, we will just save the "installation date" if the user is logged in. We
        // currently have no need for this date to be very accurate anyway so I think this is fine.
        //
        // But why do we need to check for `isAuthenticated` anyway? We don't really need too. I
        // just wanted to save a few CPU cycles so `AppSettingsAction.setInstallationDateIfNecessary`
        // is really only dispatched if the user is logged in.
        //
        // Also, note that `MainTabBarController` is **always present and active** even if the
        // user is not logged in. (◞‸◟；)
        guard storesManager.isAuthenticated else {
            return
        }
//
//        let action = AppSettingsAction.setInstallationDateIfNecessary(date: Date()) { result in
//            if case let .failure(error) = result {
//                ServiceLocator.crashLogging.logError(error)
//            }
//        }
//        storesManager.dispatch(action)
    }

    /// Listens for notifications sent when the reviews badge should reload
    ///
    func listenToReviewsBadgeReloadRequired() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(retrieveShouldShowReviewsBadgeOnHubMenuTabValue),
                                               name: .reviewsBadgeReloadRequired,
                                               object: nil)
    }

    /// Retrieves whether we should show the reviews on the Menu button and updates `shouldShowReviewsBadge`
    ///
    @objc func retrieveShouldShowReviewsBadgeOnHubMenuTabValue() {   }

    /// Listens for changes on the menu badge display logic and updates it depending on them
    ///
    func synchronizeShouldShowBadgeOnHubMenuTabLogic() {  }
}
