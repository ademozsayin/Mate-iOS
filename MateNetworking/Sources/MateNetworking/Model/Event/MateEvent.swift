//
//  MateEvent.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation
import CoreLocation

// MARK: - MateEvent
public struct MateEvent: Codable {
    public let id: Int
    public let name: String?
    public let startTime: String?
    public let categoryID: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let userID: String?
    public let address: String?
    public let latitude: String?
    public let longitude: String?
    public let maxAttendees: String?
    public let joinedAttendees: String?
    public let category: MateCategory?
    public let user: MateUser?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case startTime = "start_time"
        case categoryID = "category_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case address = "address"
        case latitude = "latitude"
        case longitude = "longitude"
        case maxAttendees = "max_attendees"
        case joinedAttendees = "joined_attendees"
        case category = "category"
        case user = "user"
    }

}
