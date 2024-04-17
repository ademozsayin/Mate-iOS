//
//  MateDeviceMapper.swift
//
//
//  Created by Adem Özsayın on 16.04.2024.
//

import Foundation

/// Mapper: Dotcom Device
///
struct MateDeviceMapper: Mapper {

    /// (Attempts) to convert an instance of Data into an array of Note Entities.
    ///
    func map(response: Data) throws -> MateDevice {
        return try JSONDecoder().decode(MateDevice.self, from: response)
    }
}
