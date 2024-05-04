import Foundation
import MateStorage


// MARK: - Yosemite.ProductReview: ReadOnlyType
//
extension FiableRedux.ProductReview: ReadOnlyType {

    /// Indicates if the receiver is a representation of a specified Storage.Entity instance.
    ///
    public func isReadOnlyRepresentation(of storageEntity: Any) -> Bool {
        guard let storageProductReview = storageEntity as? MateStorage.ProductReview else {
            return false
        }

        return storageProductReview.reviewID == reviewID
    }
}
