import Foundation


// MARK: - StorageType DataModel Specific Extensions for Deletions
//
public extension StorageType {

    // MARK: - Products

    /// Deletes all of the stored Products for the provided siteID.
    ///
    ///
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
