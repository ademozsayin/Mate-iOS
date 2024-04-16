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
import FiableRedux
import MateStorage
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject {
    
    @Published var region: MKCoordinateRegion

    @Published var trackingMode: MapUserTrackingMode = .follow

    private(set) unowned var navigationController: UINavigationController?
     
    private let stores: StoresManager
    
    private let locationManager: LocationManagerDelegate

    private var cancellables = Set<AnyCancellable>()
    
    init(
        navigationController: UINavigationController? = nil,
        stores: StoresManager = ServiceLocator.stores,
        locationManager: LocationManagerDelegate = LocationManager()
    ) {
        
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        self.navigationController = navigationController
        self.stores = stores
        self.locationManager = locationManager
        super.init()
        // Set the delegate of locationManager to self
        (locationManager as? LocationManager)?.delegate = self
        // Subscribe to changes in region
        $region
            .receive(on: DispatchQueue.main) // Ensure updates are performed on the main thread
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

    }
}

extension MapViewModel: LocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        region = MKCoordinateRegion(center: center, span: span)
    }
}
