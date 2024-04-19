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
