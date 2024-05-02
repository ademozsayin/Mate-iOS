//
//  MateEvent+ ReadOnlyConvertible.swift.swift
//
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation
import MateStorage
import MateNetworking

// MARK: - Storage.Account: ReadOnlyConvertible
//
extension StorageEvent: ReadOnlyConvertible {
   

    /// Updates the Storage.Account with the a ReadOnly.
    ///
    public func update(with event: FiableRedux.MateEvent) {
        id = Int64(event.id)
        title = event.name
        categoryID = (Int64(event.category?.id ?? 0)) as NSNumber
    }

    /// Returns a ReadOnly version of the receiver.
    ///
//    public func toReadOnly() -> FiableRedux.Account {
//        return Account(userID: id, name: username ?? "", email: email ?? "", gravatarUrl: "")
//    }
    
    public func toReadOnly() -> MateNetworking.MateEvent {
        return MateEvent(id: Int(id),
                         name: title,
                         startTime: nil,
                         categoryID: "\(categoryID ?? 0)",
                         createdAt: nil,
                         updatedAt: nil,
                         userID: nil,
                         address: nil,
                         latitude: nil,
                         longitude: nil,
                         maxAttendees: nil,
                         joinedAttendees: nil,
                         category: nil,
                         user: nil,
                         status: nil
        )
    }
    
}
