//
//  WeatherRequest+CLLocation.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 27.02.2024.
//

import Networking
import CoreLocation

/// Extension to convert a CLLocation object into a WeatherRequest object.
extension CLLocation {
    /// Converts the given CLLocation object into a WeatherRequest object with latitude and longitude coordinates.
    ///
    /// - Parameter location: The CLLocation object to convert.
    /// - Returns: A WeatherRequest object with latitude and longitude coordinates derived from the given CLLocation object.
    static func asWeatherRequest(_ location: CLLocation) -> WeatherRequest {
        return WeatherRequest(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
}
