//
//  OnsaTokenData.swift
//  Networking
//
//  Created by Adem Özsayın on 1.04.2024.
//

import Foundation
import CodeGen

public struct OnsaTokenData {
    /// ID of the coupon
    public let token: String

    /// Total amount deducted from orders using the coupon
    public let expires_at: String

    public let username: String?
    
    public init(
        token: String,
        expires_at: String,
        username: String?
    ) {
        self.token = token
        self.expires_at = expires_at
        self.username = username
    }
}

// MARK: - Decodable Conformance
//
extension OnsaTokenData: Codable {
    /// Defines all of the CouponReport CodingKeys
    /// The model is intended to be decoded with`JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase`
    /// so any specific `CodingKeys` provided here should be in camel case.
    enum CodingKeys: String, CodingKey {
        case token
        case expires_at
        case username
    }
}

// MARK: - Other Conformance
//
extension OnsaTokenData: GeneratedCopiable, GeneratedFakeable, Equatable {}
