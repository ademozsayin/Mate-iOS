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
import MateNetworking
import FiableRedux
import MateStorage
import CoreLocation
import MapKit

@Observable final class MapViewModel: NSObject {
    
    // MARK: - Properties
    private(set) var manager: CLLocationManager?
    private(set) weak var delegate: CLLocationManagerDelegate?
    private(set) unowned var navigationController: UINavigationController?
    private let stores: StoresManager
    
    var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
    
    var userLocation: CLLocationCoordinate2D?
    private(set) var syncState = SyncState.loading
    var events: [MateEvent] = []
    
    var onReload: (() -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        navigationController: UINavigationController? = nil,
        stores: StoresManager = ServiceLocator.stores,
        manager: CLLocationManager = CLLocationManager()
    ) {
        self.navigationController = navigationController
        self.stores = stores
        
        super.init()
        self.manager = manager
        self.manager?.delegate = self
//        self.manager?.desiredAccuracy = .greatestFiniteMagnitude
    }
    
    // MARK: - Private func
    private func checkLocationPermissions() {
        switch manager?.authorizationStatus {
        case .restricted, .notDetermined:
            manager?.requestWhenInUseAuthorization()
        case .denied:
            manager?.requestWhenInUseAuthorization()
            syncState = .error(error: .locationPermissionDenied)
            return
        default:
            manager?.startUpdatingLocation()
        }
    }
    
    func fetch() {
        manager?.startUpdatingLocation()
    }
    
    @MainActor
    func fetchEvents(location: CLLocationCoordinate2D) async {
    
        syncState = .loading
        
        // Check location permissions
        let permissionStatus = manager?.authorizationStatus ?? .denied
        if permissionStatus == .denied {
            syncState = .error(error: .locationPermissionDenied)
        } else {
            do {
                events = try await loadNearByEvents(latitude: location.latitude, longitude: location.longitude)
                syncState = .content(events: events)
            } catch {
                DDLogError("⛔️ Error loading suggested events: \(error)")
                syncState = .error(error: .apiError)
            }
        }
    }
    
    @MainActor
    func loadNearByEvents(latitude: Double, longitude: Double) async throws -> [MateEvent] {
        try await withCheckedThrowingContinuation { continuation in
            stores.dispatch(EventAction.getNearByEvents(
                    latitude: latitude,
                    longitude: longitude,
                    categoryId: nil,
                    completion: { result in
                        switch result {
                        case .success(let data):
                            continuation.resume(returning: data)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                )
            )
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationPermissions()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location.coordinate
            guard let userLocation else { return }
            cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude:userLocation.latitude,
                    longitude: userLocation.longitude
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: Metrics.delta,
                    longitudeDelta: Metrics.delta
                )
            ))
            self.manager?.stopUpdatingLocation()
            Task {
                await fetchEvents(location: userLocation) // Fetch events once the location is obtained
            }
        }
    }
}

private extension MapViewModel {
    struct Metrics {
        static let delta = 0.01
    }
}

extension MapViewModel {
    enum SyncState: Equatable {
        case loading
        case error(error: ErrorType)
        case content(events: [MateEvent])
    }
    
    enum ErrorType {
        case apiError
        case locationPermissionDenied
    }
}

