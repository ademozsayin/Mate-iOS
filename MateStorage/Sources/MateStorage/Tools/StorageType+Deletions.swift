import Foundation


// MARK: - StorageType DataModel Specific Extensions for Deletions
//
public extension StorageType {

    // MARK: - User Event

    /// Deletes all of the stored UserEvent
    func deleteProducts() {
        guard let products = loadUserEvents() else {
            return
        }
        for product in products {
            deleteObject(product)
        }
    }

    ///
    // MARK: - InboxNotes

    /// Deletes all of the stored Inbox Notes for the provided siteID.
    ///
    func deleteInboxNotes(siteID: Int64) {
        let inboxNotes = loadAllInboxNotes(siteID: siteID)
        for inboxNote in inboxNotes {
            deleteObject(inboxNote)
        }
    }

    /// Deletes the stored InboxNote with the given id for the provided siteID.
    ///
    func deleteInboxNote(siteID: Int64, id: Int64) {
        if let inboxNote = loadInboxNote(siteID: siteID, id: id) {
            deleteObject(inboxNote)
        }
    }

}
