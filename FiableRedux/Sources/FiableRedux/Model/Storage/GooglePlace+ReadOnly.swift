//
//  GooglePlace+ReadOnly.swift
//
//
//  Created by Adem Özsayın on 29.04.2024.
//

import Foundation
import MateStorage

// MARK: - Storage.Account: ReadOnlyConvertible
//
extension MateStorage.GooglePlace: ReadOnlyConvertible {
    
    /// Updates the Storage.Account with the a ReadOnly.
    ///
    public func update(with place: FiableRedux.GooglePlace) {
        id = Int64(place.id)
        name = place.name
        if let rating = place.rating {
            self.rating = NSNumber(value: rating)
        } else {
            self.rating = nil
        }
        if let longitude = Double(place.longitude) {
            self.longitude = NSNumber(value: longitude)
        } else {
            self.longitude = nil
        }
        
        if let latitude = Double(place.latitude ) {
            self.latitude = NSNumber(value: latitude)
        } else {
            self.latitude = nil
        }
        
        self.vicinity = place.vicinity
        self.place_id = place.placeID
        self.event_category_id = (Int64(place.eventCategoryID)) as NSNumber
    }
    
    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> FiableRedux.GooglePlace {
        
        // Convert NSNumber? to String
        let convertedLongitude: String
        if let longitudeNumber = self.longitude {
            convertedLongitude = String(describing: longitudeNumber)
        } else {
            // Handle the case where self.longitude is nil
            // You can set a default value or handle it based on your requirements
            convertedLongitude = ""
        }
        
        let convertedLatitude: String
        if let latitudeNumber = self.latitude {
            convertedLatitude = String(describing: latitudeNumber)
        } else {
            // Handle the case where self.longitude is nil
            // You can set a default value or handle it based on your requirements
            convertedLatitude = ""
        }
        
        // Convert NSNumber? to Int
        let eventCategoryID: Int
        
        if let eventCategoryIDNumber = event_category_id {
            eventCategoryID = eventCategoryIDNumber.intValue
        } else {
            // Handle the case where event_category_id is nil
            // You can set a default value or handle it based on your requirements
            eventCategoryID = 0
        }
        
        return GooglePlace(
            id: Int(id),
            placeID: place_id ?? "",
            name: name,
            rating: Double(truncating: rating ?? 0.0),
            scope: "Google",
            vicinity: vicinity ?? "",
            createdAt: nil,
            updatedAt: nil,
            latitude: convertedLatitude,
            longitude: convertedLongitude,
            eventCategoryID: eventCategoryID)
    }
}
