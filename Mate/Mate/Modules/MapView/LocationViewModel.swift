//
//  LocationViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 19.04.2024.
//

import CoreLocation
import MapKit
import SwiftUI
import Observation

@Observable
class LocationViewModel: NSObject, CLLocationManagerDelegate {
    
    var userLocation: CLLocationCoordinate2D? {
        didSet {
            print("user location: \(userLocation)")
        }
    }
    
    var authorizationStatus: CLAuthorizationStatus?

    var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.011_286, longitude: -116.166_868),
            span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    ))
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latestLocation = locations.last else { return }
        userLocation = latestLocation.coordinate
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
        
        locationManager.stopUpdatingLocation() // Stop updating after getting location
    }
}

private extension LocationViewModel {
    struct Metrics {
        static let delta = 0.01
    }
}
