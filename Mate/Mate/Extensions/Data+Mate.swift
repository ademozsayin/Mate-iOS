//
//  Data+Mate.swift
//  Mate
//
//  Created by Adem Özsayın on 16.04.2024.
//

import Foundation

// MARK: - Data Extensions
//
extension Data {

    /// Returns the contained data represented as an hexadecimal string
    ///
    var hexString: String {
        return reduce("") { (output, byte) in
            output + String(format: "%02x", byte)
        }
    }
}
