import Foundation
import MateStorage


// MARK: - FiableRedux.Account: ReadOnlyType
//
extension FiableRedux.Account: ReadOnlyType {

    /// Indicates if the receiver is a representation of a specified Storage.Entity instance.
    ///
    public func isReadOnlyRepresentation(of storageEntity: Any) -> Bool {
        guard let storageAccount = storageEntity as? MateStorage.Account else {
            return false
        }

        return Int(storageAccount.id) == userID
    }
}
