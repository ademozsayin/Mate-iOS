//
//  File.swift
//  
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation
import MateStorage


// MARK: - Storage.InboxNote: ReadOnlyConvertible
//
extension MateStorage.InboxNote: ReadOnlyConvertible {

    /// Updates the `Storage.InboxNote` from the ReadOnly representation (`Networking.InboxNote`)
    ///
    public func update(with inboxNote: FiableRedux.InboxNote) {
        siteID = inboxNote.siteID ?? 0
        id = inboxNote.id
        name = inboxNote.name
        type = inboxNote.type
        status = inboxNote.status
        title = inboxNote.title
        content = inboxNote.content
        isRemoved = inboxNote.isRemoved
        isRead = inboxNote.isRead
        dateCreated = inboxNote.dateCreated
    }

    /// Returns a ReadOnly (`Networking.InboxNote`) version of the `Storage.InboxNote`
    ///
    public func toReadOnly() -> FiableRedux.InboxNote {
        return FiableRedux.InboxNote(siteID: siteID,
                                  id: id,
                                  name: name ?? "",
                                  type: type ?? "",
                                  status: status ?? "",
                                  actions: actions?.map { $0.toReadOnly() } ?? [FiableRedux.InboxAction](),
                                  title: title ?? "",
                                  content: content ?? "",
                                  isRemoved: isRemoved,
                                  isRead: isRead,
                                  dateCreated: dateCreated ?? Date())
    }
}
