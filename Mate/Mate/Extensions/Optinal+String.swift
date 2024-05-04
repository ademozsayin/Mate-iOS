//
//  Optinal+String.swift
//  Mate
//
//  Created by Adem Özsayın on 4.05.2024.
//

import Foundation

extension Optional where Wrapped == String {
    var isNilOrEmpty: Bool {
        guard let self = self else {
            return true
        }
        return self.isEmpty
    }
}
