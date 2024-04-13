//
//  MagicLinkMapper.swift
//
//
//  Created by Adem Özsayın on 12.04.2024.
//

import Foundation

struct MagicLinkMapper: Mapper {

    func map(response: Data) throws -> String {
        let decoder = JSONDecoder()
        if hasDataEnvelope(in: response) {
            return try decoder.decode(MagicLinkMapperEnvelope.self, from: response).data
        } else {
            return try decoder.decode(String.self, from: response)
        }
    }
}

private struct MagicLinkMapperEnvelope: Decodable {
    let data: String
    private enum CodingKeys: String, CodingKey {
        case data = "message"
    }
}
