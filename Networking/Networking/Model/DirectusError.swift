//
//  DirectusError.swift
//  Networking
//
//  Created by Adem Özsayın on 28.03.2024.
//

import Foundation
import CodeGen
// Define your custom error type conforming to Error
public struct DirectusError: Error, Decodable {
    public let errors: [InnerError]?

    enum CodingKeys: String, CodingKey {
        case errors
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.errors = try container.decodeIfPresent([InnerError].self, forKey: .errors)
    }
}

// Define your nested Error type
public struct InnerError: Error, Decodable {
    public let message: String?
    public let extensions: Extensions?

    enum CodingKeys: String, CodingKey {
        case message, extensions
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.extensions = try container.decodeIfPresent(Extensions.self, forKey: .extensions)
    }
}

// Define Extensions struct
public struct Extensions: Decodable {
    public let code: String?
    public let path: String?

    enum CodingKeys: String, CodingKey {
        case code, path
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.code = try container.decodeIfPresent(String.self, forKey: .code)
        self.path = try container.decodeIfPresent(String.self, forKey: .path)
    }
}
