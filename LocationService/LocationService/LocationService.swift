//
//  LocationService.swift
//  LocationService
//
//  Created by Adem Özsayın on 27.02.2024.
//

/// Import CoreLocation framework for location services.
import CoreLocation

/// Delegate protocol for handling location service events.
protocol LocationServiceDelegate: AnyObject {
    /// Called when user location is successfully fetched.
    ///
    /// - Parameter location: The user's location.
    func didFetchUserLocation(_ location: CLLocation)
    
    /// Called when there is a failure in fetching user location.
    ///
    /// - Parameter error: The error encountered while fetching location.
    func didFailToFetchUserLocation(withError error: Error)
}

/// Service class responsible for handling location-related operations.
class LocationService: NSObject, CLLocationManagerDelegate {
    /// Shared instance of LocationService.
    static let shared = LocationService()
    
    /// Core Location manager for managing location-related tasks.
    private let locationManager = CLLocationManager()
    
    /// Delegate for handling location service events.
    weak var delegate: LocationServiceDelegate?
    
    /// Private initializer to enforce singleton pattern.
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    /// Requests user's location.
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didFetchUserLocation(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailToFetchUserLocation(withError: error)
    }
}
