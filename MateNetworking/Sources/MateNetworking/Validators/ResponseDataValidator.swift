//
//  ResponseDataValidator.swift
//  Networking
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Foundation

protocol ResponseDataValidator {
    /// Throws an error contained in a given Data Instance (if any).
    ///
    func validate(data: Data) throws -> Void
}
