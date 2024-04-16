//
//  MapCoordinator.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import Combine
import Foundation
import UIKit
import FiableRedux

final class MapCoordinator: Coordinator {
   
    let navigationController: UINavigationController
    var mapViewController: MapViewController?
    private let storesManager: StoresManager
    private let willPresentReviewDetailsFromPushNotification: () async -> Void
    
    init(navigationController: UINavigationController,
         storesManager: StoresManager = ServiceLocator.stores,
         willPresentReviewDetailsFromPushNotification: @escaping () async -> Void) {
        self.storesManager = storesManager
        self.willPresentReviewDetailsFromPushNotification = willPresentReviewDetailsFromPushNotification
        self.navigationController = navigationController
    }

    convenience init(navigationController: UINavigationController,
                     willPresentReviewDetailsFromPushNotification: @escaping () async -> Void)
    {
        let storesManager = ServiceLocator.stores
        self.init(
            navigationController: navigationController,
            storesManager: storesManager,
            willPresentReviewDetailsFromPushNotification: willPresentReviewDetailsFromPushNotification)
    }

    deinit { }
    
    func start() {
        // No-op: please call `activate(siteID:)` instead when the menu tab is configured.
    }
    
    /// Replaces `start()` because the menu tab's navigation stack could be updated multiple times when site ID changes.
    func activate() {
        mapViewController = MapViewController(navigationController: navigationController)
        if let mapViewController = mapViewController {
            navigationController.viewControllers = [mapViewController]
        }
    }
}
