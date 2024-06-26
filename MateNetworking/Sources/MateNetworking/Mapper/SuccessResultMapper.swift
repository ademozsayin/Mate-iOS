//
//  SuccessResultMapper.swift
//  
//
//  Created by Adem Özsayın on 16.04.2024.
//

import Foundation


/// Mapper: Success Result
///
struct SuccessResultMapper: Mapper {

    /// (Attempts) to extract the `success` flag from a given JSON Encoded response.
    ///
    func map(response: Data) throws -> Bool {
        return try JSONDecoder().decode(SuccessResult.self, from: response).success
    }
}


/// Success Flag Envelope
///
public struct SuccessResult: Decodable {

    /// Success Flag
    ///
    let success: Bool

    /// Coding Keys!
    ///
    private enum CodingKeys: String, CodingKey {
        case success
    }
}
