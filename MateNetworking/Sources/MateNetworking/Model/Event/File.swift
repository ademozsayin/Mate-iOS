//
//  File.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation

// MARK: - EventPayload
public struct EventPayload: Codable {
    public let currentPage: Int?
    public let data: [Event]?
    public let firstPageURL: String?
    public let from: Int?
    public let lastPage: Int?
    public let lastPageURL: String?
    public let links: [Link]?
    public let nextPageURL: String?
    public let path: String?
    public let perPage: Int?
    public let prevPageURL: String?
    public let to: Int?
    public let total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data = "data"
        case firstPageURL = "first_page_url"
        case from = "from"
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links = "links"
        case nextPageURL = "next_page_url"
        case path = "path"
        case perPage = "per_page"
        case prevPageURL = "prev_page_url"
        case to = "to"
        case total = "total"
    }
}

// MARK: - Datum
public struct Event: Codable {
    public let id: Int?
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
    public let category: Category?
    public let user: User?

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

// MARK: - Category
public struct Category: Codable {
    public let id: Int?
    public let name: String?
    public let createdAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - User
public struct User: Codable {
    public let id: Int?
    public let name: String?
    public let email: String?
    public let providerID: String?
    public let provider: String?
    public let emailVerifiedAt: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let magicLinkToken: String?
    public let magicLinkTokenExpiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case providerID = "provider_id"
        case provider = "provider"
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case magicLinkToken = "magic_link_token"
        case magicLinkTokenExpiresAt = "magic_link_token_expires_at"
    }

}

// MARK: - Link
public struct Link: Codable {
    public let url: String?
    public let label: String?
    public let active: Bool?

    enum CodingKeys: String, CodingKey {
        case url = "url"
        case label = "label"
        case active = "active"
    }
}
