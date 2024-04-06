//
//  MapViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import Foundation
import UIKit
import SwiftUI
import Combine
//import FiableExperiments
import FiableRedux
import MateStorage
import MapKit

class MapViewModel: ObservableObject {
   
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var trackingMode: MapUserTrackingMode = .follow

    /// The view controller that will be used for presenting the `StorePickerViewController` via `StorePickerCoordinator`
    ///
    private(set) unowned var navigationController: UINavigationController?
    
    private let stores: StoresManager

    init(
         navigationController: UINavigationController? = nil,
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService,
         stores: StoresManager = ServiceLocator.stores
    ) {
        self.navigationController = navigationController
        self.stores = stores
    }

    
}
