//
//  OnsaApiError.swift
//  Networking
//
//  Created by Adem Özsayın on 1.04.2024.
//

import Foundation

public struct OnsaApiError: Error, Decodable {
    public let error: String?

    enum CodingKeys: String, CodingKey {
        case error
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.error = try container.decodeIfPresent(String.self, forKey: .error)
    }
}
