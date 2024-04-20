//
//  Category.swift
//
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation

// MARK: - Category
public struct MateCategory: Codable {
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
