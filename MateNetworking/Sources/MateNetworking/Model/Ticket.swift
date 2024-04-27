//
//  File.swift
//
//
//  Created by Adem Özsayın on 26.04.2024.
//

import Foundation
public struct Ticket: Decodable {
    public let form_id: String?
    // public let custom_fields: [String: String]? // Use a dictionary for dynamic custom fields
    public let tags: [String]?  // Define tags as an optional array of strings
    public let subject: String?
    public let description: String?
    public let user_id: Int?
    public let status: String?
    public let updated_at: String?
    public let created_at: String?
    public let id: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        form_id = try container.decodeIfPresent(String.self, forKey: .form_id)
        subject = try container.decodeIfPresent(String.self, forKey: .subject)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        id = try container.decode(Int.self, forKey: .id)
        // Decode tags as an array of strings
        // Check if the 'tags' property is present and not null
        if let tagsContainer = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .tags) {
            // Decode the array of strings
            var tagsArray: [String] = []
            for key in tagsContainer.allKeys {
                if let tag = try? tagsContainer.decode(String.self, forKey: key) {
                    tagsArray.append(tag)
                }
            }
            tags = tagsArray
        } else {
            tags = nil
        }
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case form_id
        case tags
        case subject
        case description
        case user_id
        case status
        case updated_at
        case created_at
        case id
    }
}

