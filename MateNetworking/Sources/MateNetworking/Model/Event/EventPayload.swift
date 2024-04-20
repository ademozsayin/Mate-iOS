//
//  EventPayload.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation
import CoreLocation
import CodeGen

// MARK: - EventPayload
public struct EventPayload: Codable, GeneratedCopiable, GeneratedFakeable  {
    
    public let currentPage: Int?
    public let data: [MateEvent]?
    public let firstPageURL: String?
    public let from: Int?
    public let lastPage: Int?
    public let lastPageURL: String?
    public let links: [MateLink]?
    public let nextPageURL: String?
    public let path: String?
    public let perPage: Int?
    public let prevPageURL: String?
    public let to: Int?
    public let total: Int?

    public enum CodingKeys: String, CodingKey {
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


