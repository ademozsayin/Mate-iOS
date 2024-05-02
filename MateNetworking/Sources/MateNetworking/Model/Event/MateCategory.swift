//
//  Category.swift
//
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation

// MARK: - Category
public struct MateCategory: Codable, Equatable, Identifiable, Hashable {
    public let id: Int
    public let name: String
    public let createdAt: String?
    public let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    public init(id: Int, name: String, createdAt: String?, updatedAt: String?) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}


// MARK: - Comparable Conformance
//
extension MateCategory: Comparable {
    public static func < (lhs: MateCategory, rhs: MateCategory) -> Bool {
        return lhs.id < rhs.id ||
            (lhs.id == rhs.id && lhs.name < rhs.name) ||
            (lhs.id == rhs.id && lhs.name == rhs.name )
    }
}
