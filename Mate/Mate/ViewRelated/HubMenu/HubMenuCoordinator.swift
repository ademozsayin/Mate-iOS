//
//  HubMenuCoordinator.swift
//  Mate
//
//  Created by Adem Özsayın on 22.03.2024.
//

import Combine
import Foundation
import UIKit

//import enum Redux.ProductReviewAction
//import enum Redux.NotificationAction
//import struct Redux.ProductReviewFromNoteParcel
import protocol FiableRedux.StoresManager

final class HubMenuCoordinator: Coordinator {
    
    var hubMenuController: HubMenuViewController?
    let navigationController: UINavigationController
    private let storesManager: StoresManager
    private let willPresentReviewDetailsFromPushNotification: () async -> Void
    
    init(navigationController: UINavigationController,
         storesManager: StoresManager = ServiceLocator.stores,
         willPresentReviewDetailsFromPushNotification: @escaping () async -> Void) {
        self.storesManager = storesManager
        self.navigationController = navigationController
        self.willPresentReviewDetailsFromPushNotification = willPresentReviewDetailsFromPushNotification
    }

    convenience init(navigationController: UINavigationController,
                     willPresentReviewDetailsFromPushNotification: @escaping () async -> Void) {
        let storesManager = ServiceLocator.stores
        self.init(navigationController: navigationController,
                  storesManager: storesManager,
                  willPresentReviewDetailsFromPushNotification: willPresentReviewDetailsFromPushNotification)
    }

    deinit { }
    
    func start() {
        // No-op: please call `activate(siteID:)` instead when the menu tab is configured.
    }
    
    /// Replaces `start()` because the menu tab's navigation stack could be updated multiple times when site ID changes.
    func activate() {
//        hubMenuController = HubMenuViewController(siteID: siteID,
//                                                  navigationController: navigationController,
//                                                  tapToPayBadgePromotionChecker: tapToPayBadgePromotionChecker)
//        if let hubMenuController = hubMenuController {
//            navigationController.viewControllers = [hubMenuController]
//        }
//
//        if notificationsSubscription == nil {
//            notificationsSubscription = Publishers
//                .Merge(pushNotificationsManager.inactiveNotifications, pushNotificationsManager.foregroundNotificationsToView)
//                .sink { [weak self] in
//                    self?.handleNotification($0)
//                }
//        }
    }
}

// MARK: - Deeplinks
extension HubMenuCoordinator: DeepLinkNavigator {
    func navigate(to destination: any DeepLinkDestinationProtocol) {
        guard let hubMenuController = hubMenuController else {
            return
        }
//        hubMenuController.navigate(to: destination)
    }
}

final class HubMenuViewController: UIViewController {
}
