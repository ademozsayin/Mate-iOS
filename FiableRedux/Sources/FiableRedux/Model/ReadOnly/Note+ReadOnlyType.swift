import Foundation
import MateStorage


// MARK: - Yosemite.Note: ReadOnlyType
//
extension FiableRedux.Note: ReadOnlyType {

    /// Indicates if the receiver is a representation of a specified Storage.Entity instance.
    ///
    public func isReadOnlyRepresentation(of storageEntity: Any) -> Bool {
        guard let storageNote = storageEntity as? MateStorage.Note else {
            return false
        }

        return storageNote.noteID == noteID
    }
}
