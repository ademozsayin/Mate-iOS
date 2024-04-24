//
//  File.swift
//  
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation


struct UserEventsMapper: Mapper {
    func map(response: Data) throws -> PaginatedResponse<UserEvent> {
        let decoder = JSONDecoder()
        return try decoder.decode(PaginatedResponse<UserEvent>.self, from: response)
    }
}
