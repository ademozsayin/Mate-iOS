//
//  HubMenuCoordinator.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 22.03.2024.
//

import Combine
import Foundation
import UIKit

//import enum Redux.ProductReviewAction
//import enum Redux.NotificationAction
//import struct Redux.ProductReviewFromNoteParcel
import protocol Redux.StoresManager

final class HubMenuCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let storesManager: StoresManager
    init(navigationController: UINavigationController,
         storesManager: StoresManager = ServiceLocator.stores){
        self.storesManager = storesManager
        self.navigationController = navigationController
    }

    convenience init(navigationController: UINavigationController) {
        let storesManager = ServiceLocator.stores
        self.init(navigationController: navigationController,
                  storesManager: storesManager)
    }

    deinit { }
    
    func start() {
        // No-op: please call `activate(siteID:)` instead when the menu tab is configured.
    }
}
