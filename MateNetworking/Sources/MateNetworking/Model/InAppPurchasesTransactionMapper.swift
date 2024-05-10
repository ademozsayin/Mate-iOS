//
//  InAppPurchasesTransactionMapper.swift
//
//
//  Created by Adem Özsayın on 10.05.2024.
//


import Foundation

/// Mapper: IAP-MATE transaction verification result
///
struct InAppPurchasesTransactionMapper: Mapper {
    func map(response: Data) throws -> InAppPurchasesTransactionResponse {
        let decoder = JSONDecoder()
        return try decoder.decode(InAppPurchasesTransactionResponse.self, from: response)
    }
}

public struct InAppPurchasesTransactionResponse: Decodable {
    public let message: String?
    public let code: Int?

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let errorMessage = try container.decodeIfPresent(String.self, forKey: .message)
        let errorCode = try container.decodeIfPresent(Int.self, forKey: .code)
        self.message = errorMessage
        self.code = errorCode
    }

    private enum CodingKeys: String, CodingKey {
        case message
        case code
    }
}
