//
//  User.swift
//
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation

// MARK: - User
public struct MateUser: Codable {
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

    public enum CodingKeys: String, CodingKey {
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
