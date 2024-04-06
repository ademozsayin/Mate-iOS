//
//  FiableValidator.swift
//  Networking
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Foundation

struct FiableValidator: ResponseDataValidator {
    /// Throws a FiableError contained in a given Data Instance (if any).
    ///
    func validate(data: Data) throws {
        guard let error = try? JSONDecoder().decode(FiableError.self, from: data) else {
            return
        }
        throw error
    }
}
