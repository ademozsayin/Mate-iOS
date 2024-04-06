//
//  Token.swift
//  Networking
//
//  Created by Adem Özsayın on 1.04.2024.
//

import Foundation

struct TokenMapper: Mapper {

    func map(response: Data) throws -> OnsaTokenData {
        let decoder = JSONDecoder()
        if hasDataEnvelope(in: response) {
            return try decoder.decode(OnsaTokenDataDataEnvelope.self, from: response).data
        } else {
            return try decoder.decode(OnsaTokenData.self, from: response)
        }
    }
}

private struct OnsaTokenDataDataEnvelope: Decodable {
    let data: OnsaTokenData
    private enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
