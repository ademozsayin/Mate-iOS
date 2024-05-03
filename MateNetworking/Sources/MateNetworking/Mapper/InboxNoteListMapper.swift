//
//  InboxNoteListMapper.swift
//  
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation

struct InboxNoteListMapper: Mapper {

    /// Site we're parsing `InboxNote`s for
    ///

    /// (Attempts) to convert a dictionary into an Inbox Note Array.
    ///
    func map(response: Data) throws -> [InboxNote] {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.Defaults.dateTimeFormatter)
  
        if hasDataEnvelope(in: response) {
            return try decoder.decode(InboxNoteListEnvelope.self, from: response).data
        } else {
            return try decoder.decode([InboxNote].self, from: response)
        }
    }
}

/// InboxNoteListEnvelope Disposable Entity:
/// This entity allows us to parse [InboxNote] with JSONDecoder.
///
private struct InboxNoteListEnvelope: Decodable {
    let data: [InboxNote]

    private enum CodingKeys: String, CodingKey {
        case data
    }
}
