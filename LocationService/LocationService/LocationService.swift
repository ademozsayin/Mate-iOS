//
//  LocationService.swift
//  LocationService
//
//  Created by Adem Özsayın on 27.02.2024.
//

/// Import CoreLocation framework for location services.
import CoreLocation

/// Delegate protocol for handling location service events.
public protocol LocationServiceDelegate: AnyObject {
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
final public class LocationService: NSObject, CLLocationManagerDelegate {
    /// Shared instance of LocationService.
   public static let shared = LocationService()
    
    /// Core Location manager for managing location-related tasks.
    private let locationManager = CLLocationManager()
    
    /// Delegate for handling location service events.
    public weak var delegate: LocationServiceDelegate?
    
    /// Private initializer to enforce singleton pattern.
    private override init() {
        super.init()
        locationManager.delegate = self
    }
    
    /// Requests user's location.
    final public func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        delegate?.didFetchUserLocation(location)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.didFailToFetchUserLocation(withError: error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .notDetermined:
                // Location permission not yet determined
                // You can request permission here if needed
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                // Location services are restricted on this device
                // Handle accordingly
                print("Location services are restricted.")
            case .denied:
                // Location services are denied by the user
                // Prompt the user to enable location services
                print("Location services are denied. Please enable them in Settings.")
            case .authorizedWhenInUse, .authorizedAlways:
                // Location services are authorized
                // You can start requesting location updates here
                requestLocation()
            @unknown default:
                fatalError("Unknown authorization status")
            }
        }
}
