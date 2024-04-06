//
//  DotcomValidator.swift
//  Networking
//
//  Created by Adem Özsayın on 25.03.2024.
//

import Foundation


/// WordPress.com Response Validator
///
struct DotcomValidator: ResponseDataValidator {
    /// Throws a DotcomError contained in a given Data Instance (if any).
    ///
    func validate(data: Data) throws {
        guard let error = try? JSONDecoder().decode(DotcomError.self, from: data) else {
            return
        }
        throw error
    }
}
