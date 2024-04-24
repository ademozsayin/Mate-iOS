//
//  UserEventPayload.swift
//
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

// MARK: - UserEvent
public struct UserEvent: Codable {
    let id: Int
    let name, startTime: String
    let categoryID: Int
    let createdAt, updatedAt: String
    let userID: Int
    let address, latitude, longitude: String?
    let maxAttendees, joinedAttendees: Int
    let googlePlaceID: String
    let pivot: Pivot?

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
    }
}

// MARK: - Pivot
public struct Pivot: Codable {
    let userID, eventID: Int
    let attendanceStatus, createdAt, updatedAt: String

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case eventID = "event_id"
        case attendanceStatus = "attendance_status"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
