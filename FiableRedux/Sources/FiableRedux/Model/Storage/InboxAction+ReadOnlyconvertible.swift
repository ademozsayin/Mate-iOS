//
//  File.swift
//  
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation
import MateStorage


// MARK: - Storage.InboxAction: ReadOnlyConvertible
//
extension MateStorage.InboxAction: ReadOnlyConvertible {

    /// Updates the Storage.InboxAction with the ReadOnly.
    ///
    public func update(with inboxAction: FiableRedux.InboxAction) {
        id = inboxAction.id
        name = inboxAction.name
        label = inboxAction.label
        status = inboxAction.status
        url = inboxAction.url
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> FiableRedux.InboxAction {
        return InboxAction(id: id,
                           name: name ?? "",
                           label: label ?? "",
                           status: status ?? "",
                           url: url ?? "")
    }
}
