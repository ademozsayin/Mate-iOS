//
//  ReadOnlyType.swift
//
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation
import MateStorage


// MARK: - ReadOnlyType: Represents an Entity that cannot be modified.
//
public protocol ReadOnlyType {

    /// Indicates if the receiver is the "ReadOnly Version" of a given Storage.Entity instance.
    ///
    func isReadOnlyRepresentation(of storageEntity: Any) -> Bool
}
