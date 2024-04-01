//
//  OnsaApiValidator.swift
//  Networking
//
//  Created by Adem Özsayın on 1.04.2024.
//

import Foundation

struct OnsaApiValidator: ResponseDataValidator {
    /// Throws a FiableError contained in a given Data Instance (if any).
    ///
    func validate(data: Data) throws {
        guard let error = try? JSONDecoder().decode(OnsaApiError.self, from: data) else {
            return
        }
        throw error
    }
}
