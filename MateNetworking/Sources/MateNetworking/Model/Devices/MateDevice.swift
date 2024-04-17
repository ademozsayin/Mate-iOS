//
//  MateDevice.swift
//
//
//  Created by Adem Özsayın on 16.04.2024.
//

import Foundation


/// WordPress.com Device
///
public struct MateDevice: Decodable {

    /// Fiable Mate DeviceId
    ///
    public let deviceID: String


    /// Decodable Initializer.
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let deviceId = container.failsafeDecodeIfPresent(stringForKey: .deviceID) else {
            throw DotcomDeviceParseError.missingDeviceID
        }

        self.deviceID = deviceId
    }
}


// MARK: - Nested Types
//
extension MateDevice {

    /// Coding Keys
    ///
    private enum CodingKeys: String, CodingKey {
        case deviceID = "deviceId"
    }
}


/// Parsing Errors
///
enum DotcomDeviceParseError: Error {
    case missingDeviceID
}
