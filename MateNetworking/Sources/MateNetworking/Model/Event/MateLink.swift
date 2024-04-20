//
//  MateLink.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation
import CodeGen

// MARK: - MateLink
public struct MateLink: Codable, Equatable, Hashable, GeneratedCopiable, GeneratedFakeable {
    
    public let url: String?
    public let label: String?
    public let active: Bool?

    private enum CodingKeys: CodingKey {
        case url
        case label
        case active
    }
    
    init(url: String?, label: String?, active: Bool?) {
        self.url = url
        self.label = label
        self.active = active
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.label = try container.decodeIfPresent(String.self, forKey: .label)
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active)
    }
}


