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
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int.self, forKey: .id)
//      
//        self.placeID = try container.decode(String.self, forKey: .placeID)
//        self.name = try container.decode(String.self, forKey: .name)
//        self.rating = try container.decodeIfPresent(Double.self, forKey: .rating)
//        self.scope = try container.decode(String.self, forKey: .scope)
//        self.vicinity = try container.decode(String.self, forKey: .vicinity)
//        self.createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
//        self.updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
//        self.latitude = try container.decode(String.self, forKey: .latitude)
//        self.longitude = try container.decode(String.self, forKey: .longitude)
////        self.eventCategoryID = try container.decode(Int.self, forKey: .eventCategoryID)
//        self.eventCategoryID = container.failsafeDecodeIfPresent(targetType: Int.self,
//                                                       forKey: .eventCategoryID,
//                                                       alternativeTypes: [
//                                                        .string(transform: { Int($0) ?? 1  })
//                                                       ]) ?? 1
        let id = try container.decode(Int.self, forKey: .id)
        let placeID = try container.decode(String.self, forKey: .placeID)
        let name = try container.decode(String.self, forKey: .name)
        
        let rating = container.failsafeDecodeIfPresent(targetType: Double.self,
                                                       forKey: .rating,
                                                       alternativeTypes: [.string(transform: { Double($0) ?? 0.0 })]) ?? 0.0
        let scope = try container.decode(String.self, forKey: .scope)
        let vicinity = try container.decode(String.self, forKey: .vicinity)
        let createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        let updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt) ?? ""
        let latitude = try container.decodeIfPresent(String.self, forKey: .latitude) ?? ""
        let longitude =  try container.decodeIfPresent(String.self, forKey: .longitude) ?? ""
        let eventCategoryID = container.failsafeDecodeIfPresent(targetType: Int.self,
                                                         forKey: .eventCategoryID,
                                                         alternativeTypes: [
                                                          .string(transform: { Int($0) ?? 1  })
                                                         ]) ?? 1
        
        
        self.init(id: id,
                  placeID: placeID,
                  name: name,
                  rating: rating,
                  scope: scope,
                  vicinity: vicinity,
                  createdAt: createdAt,
                  updatedAt: updatedAt,
                  latitude: latitude,
                  longitude: longitude,
                  eventCategoryID: eventCategoryID)
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
