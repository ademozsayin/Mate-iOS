//
//  EmailAvailabilityMapper.swift
//  Networking
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Foundation


struct EmailAvailabilityMapper: Mapper {

    /// (Attempts) to convert a dictionary into `[EmailCheckData]`.
    ///
    func map(response: Data) throws -> EmailCheckData {
        let decoder = JSONDecoder()
        if hasDataEnvelope(in: response) {
            return try decoder.decode(EmailCheckDataEnvelope.self, from: response).data
        } else {
            return try decoder.decode(EmailCheckData.self, from: response)
        }
    }
}

private struct EmailCheckDataEnvelope: Decodable {
    let data: EmailCheckData
    let success: Bool?
    private enum CodingKeys: String, CodingKey {
        case data = "data"
        case success
    }
}
