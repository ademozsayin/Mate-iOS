import Foundation
import FiableFoundation


// MARK: - StorageType DataModel Specific Extensions
//
public extension StorageType {
    /// Retrieves the Stored Account.
    ///
    func loadAccount(userID: Int64) -> Account? {
        let predicate = \Account.id == userID
        return firstObject(ofType: Account.self, matching: predicate)
    }
    
    /// Retrieves the all of the stored Product Categories for a `siteID`.
    ///
    func loadProductCategories() -> [EventCategory] {
//        let predicate = \ProductCategory.siteID == siteID
        return allObjects(ofType: EventCategory.self, matching: nil, sortedBy: nil)
    }

    /// Retrieves the Stored Product Category.
    ///
    func loadProductCategory( categoryID: Int64) -> EventCategory? {
        let predicate = \EventCategory.id == categoryID
        return firstObject(ofType: EventCategory.self, matching: predicate)
    }

    
    /// Returns a single stored add-on group for a provided `siteID` and `groupID`.
    ///
    func loadGooglePlace(placeId: String) -> GooglePlace? {
        let predicate = \GooglePlace.place_id == placeId
        return firstObject(ofType: GooglePlace.self, matching: predicate)
    }

    
    
    // MARK: - Inbox Notes

    /// Returns a single Inbox Note given a `siteID` and `id`
    ///
    func loadInboxNote(siteID: Int64, id: Int64) -> InboxNote? {
        let predicate = \InboxNote.siteID == siteID && \InboxNote.id == id
        return firstObject(ofType: InboxNote.self, matching: predicate)
    }

    /// Returns all stored Inbox Notes for a provided `siteID`.
    ///
    func loadAllInboxNotes(siteID: Int64) -> [InboxNote] {
        let predicate = \InboxNote.siteID == siteID
        let descriptor = NSSortDescriptor(keyPath: \InboxNote.dateCreated, ascending: false)
        return allObjects(ofType: InboxNote.self, matching: predicate, sortedBy: [descriptor])
    }
}
