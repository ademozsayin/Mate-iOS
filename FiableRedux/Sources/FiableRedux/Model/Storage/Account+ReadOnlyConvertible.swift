//
//  File.swift
//  
//
//  Created by Adem Özsayın on 6.04.2024.
//

import Foundation
import MateStorage


// MARK: - Storage.Account: ReadOnlyConvertible
//
extension MateStorage.Account: ReadOnlyConvertible {

    /// Updates the Storage.Account with the a ReadOnly.
    ///
    public func update(with account: FiableRedux.Account) {
        email = account.email
        id = account.userID
        username = account.name
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> FiableRedux.Account {
        return Account(userID: id, name: username ?? "", email: email ?? "")
    }
}
