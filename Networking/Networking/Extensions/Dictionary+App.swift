//
//  Dictionary+App.swift
//  Networking
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Foundation


// MARK: - Dictionary: JSON Encoding Helpers
//
extension Dictionary where Key: Hashable, Value: Any {

    /// Returns a String with the JSON Representation of the receiver.
    ///
    func toJSONEncoded() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        guard let data = jsonData else {return nil}
        return String(data: data, encoding: .utf8)
    }
}
