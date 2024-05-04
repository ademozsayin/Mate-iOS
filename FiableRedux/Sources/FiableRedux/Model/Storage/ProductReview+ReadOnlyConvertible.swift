//
//  File.swift
//  
//
//  Created by Adem Özsayın on 4.05.2024.
//

import Foundation
import MateStorage


// MARK: - Storage.ProductReview: ReadOnlyConvertible
//
extension MateStorage.ProductReview: ReadOnlyConvertible {

    /// Updates the Storage.ProductReview with the ReadOnly.
    ///
    public func update(with review: FiableRedux.ProductReview) {
//        siteID              = review.siteID
        reviewID            = review.reviewID
        productID           = review.productID
        dateCreated         = review.dateCreated
        statusKey           = review.statusKey
        reviewer            = review.reviewer
        reviewerEmail       = review.reviewerEmail
        reviewerAvatarURL   = review.reviewerAvatarURL
        self.review         = review.review
        rating              = Int64(review.rating)
        verified            = review.verified
    }

    /// Returns a ReadOnly version of the receiver.
    ///
    public func toReadOnly() -> FiableRedux.ProductReview {
        return ProductReview(reviewID: reviewID,
                             productID: productID,
                             dateCreated: dateCreated ?? Date(),
                             statusKey: statusKey ?? "",
                             reviewer: reviewer ?? "",
                             reviewerEmail: reviewerEmail ?? "",
                             reviewerAvatarURL: reviewerAvatarURL,
                             review: review ?? "",
                             rating: Int(rating),
                             verified: verified)
    }
}
