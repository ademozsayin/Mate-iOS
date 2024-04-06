//
//  AccountMapper.swift
//
//
//  Created by Adem Özsayın on 6.04.2024.
//

import Foundation
/// Mapper: Account
///


struct AccountMapper: Mapper {

    func map(response: Data) throws -> Account {
        let decoder = JSONDecoder()
        if hasDataEnvelope(in: response) {
            return try decoder.decode(AccountEnvelope.self, from: response).data
        } else {
            return try decoder.decode(Account.self, from: response)
        }
    }
}

private struct AccountEnvelope: Decodable {
    let data: Account
    private enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}
