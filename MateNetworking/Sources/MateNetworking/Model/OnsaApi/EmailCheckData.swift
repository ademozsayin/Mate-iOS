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
    public let exists: Bool

    /// Total amount deducted from orders using the coupon
    public let email: String

    public init(
        exists: Bool,
        email: String
    ) {
        self.exists = exists
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
        case exists
        case email
    }
}

// MARK: - Other Conformance
//
extension EmailCheckData: GeneratedCopiable, GeneratedFakeable, Equatable {}
