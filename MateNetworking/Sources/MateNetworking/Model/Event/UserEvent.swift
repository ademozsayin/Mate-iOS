//
//  UserEventPayload.swift
//
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

// MARK: - UserEvent
public struct UserEvent: Codable {
    public let id: Int
    public let name, startTime: String
    public let categoryID: String
    public let createdAt, updatedAt: String?
    public let userID: String
    public let address, latitude, longitude: String?
    public let maxAttendees, joinedAttendees: String
    public let googlePlaceID: String
    public  let pivot: Pivot?
    public let statusKey: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name
        case startTime = "start_time"
        case categoryID = "category_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case userID = "user_id"
        case address, latitude, longitude
        case maxAttendees = "max_attendees"
        case joinedAttendees = "joined_attendees"
        case googlePlaceID = "google_place_id"
        case pivot
        case statusKey
    }
    
    public init(id: Int, name: String, startTime: String, categoryID: String, createdAt: String?, updatedAt: String?, userID: String, address: String?, latitude: String?, longitude: String?, maxAttendees: String, joinedAttendees: String, googlePlaceID: String, pivot: Pivot?, statusKey: String?) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.categoryID = categoryID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.userID = userID
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.maxAttendees = maxAttendees
        self.joinedAttendees = joinedAttendees
        self.googlePlaceID = googlePlaceID
        self.pivot = pivot
        self.statusKey = statusKey
    }
    
    /// Computed Properties
    ///
    public var productStatus: EventStatus {
        return EventStatus(rawValue: statusKey ?? EventStatus.custom("default").rawValue)
    }
}

// MARK: - Pivot
public struct Pivot: Codable {
    public let userID, eventID: String
    public let attendanceStatus, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case eventID = "event_id"
        case attendanceStatus = "attendance_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(userID: String, eventID: String, attendanceStatus: String, createdAt: String, updatedAt: String) {
        self.userID = userID
        self.eventID = eventID
        self.attendanceStatus = attendanceStatus
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
