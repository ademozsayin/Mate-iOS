//
//  SpotlightManager.swift
//  Mate
//
//  Created by Adem Özsayın on 12.04.2024.
//

import CoreSpotlight
import Foundation

struct SpotlightManager {
    static func handleUserActivity(_ userActivity: NSUserActivity) {
        var type: WooActivityType?
        switch userActivity.activityType {
        case WooActivityType.dashboard.rawValue:
            MainTabBarController.switchToMyStoreTab()
            type = WooActivityType.dashboard
        case WooActivityType.orders.rawValue:
            MainTabBarController.switchToOrdersTab()
            type = WooActivityType.orders
        case WooActivityType.products.rawValue:
            MainTabBarController.switchToProductsTab()
            type = WooActivityType.products
        case WooActivityType.payments.rawValue:
//            MainTabBarController.presentPayments()
            type = WooActivityType.payments
        default:
            break
        }

        trackActivityBeingOpenedIfNecessary(with: type)
    }

    private static func trackActivityBeingOpenedIfNecessary(with type: WooActivityType?) {
        guard let type = type else {
            return
        }

//        ServiceLocator.analytics.track(event: FiableAnalyticsEvent.Spotlight.activityWasOpened(with: type))
    }
}
