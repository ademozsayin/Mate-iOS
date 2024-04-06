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
}
