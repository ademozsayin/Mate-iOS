//
//  EventPayloadMapper.swift
//
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation


struct EventPayloadMapper: Mapper {
    func map(response: Data) throws -> EventPayload {
        let decoder = JSONDecoder()
        return try decoder.decode(EventPayload.self, from: response)
    }
}

struct NearbyEventMapper: Mapper {
    func map(response: Data) throws -> [MateEvent] {
        let decoder = JSONDecoder()
        return try decoder.decode(NearbyEventPayloadMapper.self, from: response).data
    }
}

struct NearbyEventPayloadMapper: Decodable {
    let data: [MateEvent]
    private enum CodingKeys: String, CodingKey {
        case data = "events"
    }
}
