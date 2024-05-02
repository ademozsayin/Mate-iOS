//
//  GooglePlace.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import Observation
import SwiftUI

// MARK: - GooglePlace
public struct GooglePlace: Codable, Hashable {
    
    public let id: Int
    public let placeID, name: String
    public let rating: Double?
    public let scope, vicinity: String
    public let createdAt, updatedAt: String?
    public let latitude, longitude: String
    public let eventCategoryID: Int

    enum CodingKeys: String, CodingKey {
        case id
        case placeID = "place_id"
        case name, rating, scope, vicinity
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case latitude, longitude
        case eventCategoryID = "event_category_id"
    }
    
    public init(id: Int, placeID: String, name: String, rating: Double?, scope: String, vicinity: String, createdAt: String?, updatedAt: String?, latitude: String, longitude: String, eventCategoryID: Int) {
        self.id = id
        self.placeID = placeID
        self.name = name
        self.rating = rating
        self.scope = scope
        self.vicinity = vicinity
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.latitude = latitude
        self.longitude = longitude
        self.eventCategoryID = eventCategoryID
    }
}

public extension GooglePlace {
    static func emptyPlace() -> GooglePlace {
        return GooglePlace(id: -1,
                           placeID: "",
                           name: "",
                           rating: 0,
                           scope: "",
                           vicinity: "",
                           createdAt: "",
                           updatedAt: "",
                           latitude: "",
                           longitude: "",
                           eventCategoryID: -1)
    }
}
