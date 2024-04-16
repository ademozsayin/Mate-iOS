//
//  LocationManager.swift
//  Mate
//
//  Created by Adem Özsayın on 16.04.2024.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let locationManager = CLLocationManager()
    weak var delegate:LocationManagerDelegate? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        requestLocationPermission()
    }

    func requestLocationPermission() {
        switch self.locationManager.authorizationStatus {
        case .restricted, .denied:
            print("restricted")
        case .authorizedAlways:
            print("authorizedAlways")
            locationManager.startUpdatingLocation()
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            print("notDetermined")
        default:
            print("default")
        }
    }
}

extension LocationManager: LocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        delegate?.locationManager(manager, didUpdateLocations: locations)
    }
}
