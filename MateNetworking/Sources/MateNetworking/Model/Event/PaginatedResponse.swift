//
//  PaginatedResponse.swift
//
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

public struct PaginatedResponse<T: Codable>: Codable {
    public let currentPage: Int
    public let data: [T]?
    public let firstPageURL: String
    public let from, lastPage: Int
    public let lastPageURL: String
    public let links: [MateLink]
    public let path: String
    public let perPage: Int
    public let to, total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case data
        case firstPageURL = "first_page_url"
        case from
        case lastPage = "last_page"
        case lastPageURL = "last_page_url"
        case links
        case path
        case perPage = "per_page"
        case to, total
    }
}
