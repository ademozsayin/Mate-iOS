//
//  BaseResponse.swift
//  FiableNetwork
//
//  Created by Adem Özsayın on 1/12/23.
//

import Foundation


public struct BaseResponse<T: Codable>: Codable {

    // MARK: - Properties
    public var data: T?
    public var message: String?
    public var error: String?
    
    public enum CodingKeys: String, CodingKey {

        case data = "data"
        case error
        case message
    }

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        data = try keyedContainer.decodeIfPresent(T.self, forKey: .data)
        message = try keyedContainer.decodeIfPresent(String.self, forKey: .message)
        error = try keyedContainer.decodeIfPresent(String.self, forKey: .error)
    }
}

