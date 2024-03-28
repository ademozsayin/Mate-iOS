//
//  CheckEmailExistAccountData.swift
//  Networking
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Foundation
import CodeGen

public struct EmailCheckData {
    /// ID of the coupon
    public let id: String

    /// Total amount deducted from orders using the coupon
    public let email: String

    public init(
        id: String,
        email: String
    ) {
        self.id = id
        self.email = email
    }
}

// MARK: - Decodable Conformance
//
extension EmailCheckData: Decodable {
    /// Defines all of the CouponReport CodingKeys
    /// The model is intended to be decoded with`JSONDecoder.KeyDecodingStrategy.convertFromSnakeCase`
    /// so any specific `CodingKeys` provided here should be in camel case.
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case email
    }
}

// MARK: - Other Conformance
//
extension EmailCheckData: GeneratedCopiable, GeneratedFakeable, Equatable {}
