//
//  Event+Coordinate.swift
//  Mate
//
//  Created by Adem Özsayın on 20.04.2024.
//

import Foundation
import MateNetworking
import CoreLocation

public extension MateEvent {
    var coordinate: CLLocationCoordinate2D? {
        guard let latitude,
              let longitude,
              let latitudeAsDouble = Double(latitude),
              let longitudeAsDouble = Double(longitude) else {
            return nil
        }

        return CLLocationCoordinate2D(latitude: latitudeAsDouble, longitude: longitudeAsDouble)
    }
}
