//
//  EventCategory+ReadOnlyConvertible.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import MateStorage


// MARK: - Storage.ProductCategory: ReadOnlyConvertible
//
extension MateStorage.EventCategory: ReadOnlyConvertible {

    /// Updates the Storage.ProductCategory with the ReadOnly.
    ///
    public func update(with category: FiableRedux.MateCategory) {
        id = Int64(category.id)
        name = category.name
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> FiableRedux.MateCategory {
        return MateCategory(
            id: Int(id),
            name: name ?? "",
            createdAt: nil,
            updatedAt: nil)
    }
}
