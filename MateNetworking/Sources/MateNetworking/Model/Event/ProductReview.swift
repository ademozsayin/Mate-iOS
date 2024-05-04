//
//  ProductReview.swift
//
//
//  Created by Adem Özsayın on 4.05.2024.
//

import Foundation
import CodeGen

/// Represents a ProductReview Entity.
///
public struct ProductReview: Decodable, Equatable, GeneratedFakeable, GeneratedCopiable {
//    public let siteID: Int64
    public let reviewID: Int64
    public let productID: Int64

    public let dateCreated: Date        // gmt

    public let statusKey: String

    public let reviewer: String
    public let reviewerEmail: String
    public let reviewerAvatarURL: String?

    public let review: String
    public let rating: Int

    public let verified: Bool

    public var status: ProductReviewStatus {
        return ProductReviewStatus(rawValue: statusKey)
    }

    /// ProductReview struct initializer.
    ///
    public init(reviewID: Int64,
                productID: Int64,
                dateCreated: Date,
                statusKey: String,
                reviewer: String,
                reviewerEmail: String,
                reviewerAvatarURL: String?,
                review: String,
                rating: Int,
                verified: Bool) {
        self.reviewID = reviewID
        self.productID = productID
        self.dateCreated = dateCreated
        self.statusKey = statusKey
        self.reviewer = reviewer
        self.reviewerEmail = reviewerEmail
        self.reviewerAvatarURL = reviewerAvatarURL
        self.review = review
        self.rating = rating
        self.verified = verified
    }

    /// The public initializer for ProductReview.
    ///
    public init(from decoder: Decoder) throws {
//        guard let siteID = decoder.userInfo[.siteID] as? Int64 else {
//            throw ProductReviewDecodingError.missingSiteID
//        }

        let container = try decoder.container(keyedBy: CodingKeys.self)

        let reviewID = try container.decode(Int64.self, forKey: .reviewID)
        let productID = try container.decode(Int64.self, forKey: .productID)
        let dateCreated = (try? container.decodeIfPresent(Date.self, forKey: .dateCreated)) ?? Date()
        let statusKey = try container.decode(String.self, forKey: .status)
        let reviewer = try container.decode(String.self, forKey: .reviewer)
        let reviewerEmail = try container.decode(String.self, forKey: .reviewerEmail)
        let avatarURLs = try container.decodeIfPresent(ReviewerAvatarURLs.self, forKey: .avatarURLs)
        let review = try container.decode(String.self, forKey: .review)
        let rating = try container.decode(Int.self, forKey: .rating)
        let verified = try container.decode(Bool.self, forKey: .verified)

        self.init(reviewID: reviewID,
                  productID: productID,
                  dateCreated: dateCreated,
                  statusKey: statusKey,
                  reviewer: reviewer,
                  reviewerEmail: reviewerEmail,
                  reviewerAvatarURL: avatarURLs?.url96,
                  review: review,
                  rating: rating,
                  verified: verified)
    }
}


/// Defines all of the ProductReview CodingKeys
///
private extension ProductReview {

    enum CodingKeys: String, CodingKey {
        case reviewID       = "id"
        case productID      = "product_id"
        case dateCreated    = "date_created_gmt"
        case status         = "status"
        case reviewer       = "reviewer"
        case reviewerEmail  = "reviewer_email"
        case avatarURLs     = "reviewer_avatar_urls"
        case review         = "review"
        case rating         = "rating"
        case verified       = "verified"
    }

    struct ReviewerAvatarURLs: Decodable {
        /// The URL of the "96" key in the JSON.
        ///
        /// We are ignoring all avatars except the one marked as 96
        /// to avoid adding an unecessary intermediate object
        let url96: String?

        enum CodingKeys: String, CodingKey {
            case url96 = "96"
        }
    }
}

// MARK: - Decoding Errors
//
enum ProductReviewDecodingError: Error {
    case missingSiteID
}


/// Represents a ProductReviewStatus Entity.
///
public enum ProductReviewStatus: Decodable, Hashable, GeneratedFakeable {
    case approved
    case hold
    case spam
    case unspam
    case trash
    case untrash
}


/// RawRepresentable Conformance
///
extension ProductReviewStatus: RawRepresentable {

    /// Designated Initializer.
    ///
    public init(rawValue: String) {
        switch rawValue {
        case Keys.approved:
            self = .approved
        case Keys.hold:
            self = .hold
        case Keys.spam:
            self = .spam
        case Keys.unspam:
            self = .unspam
        case Keys.trash:
            self = .trash
        case Keys.untrash:
            self = .untrash
        default:
            self = .hold
        }
    }

    /// Returns the current Enum Case's Raw Value
    ///
    public var rawValue: String {
        switch self {
        case .approved: return Keys.approved
        case .hold:     return Keys.hold
        case .spam:     return Keys.spam
        case .unspam:   return Keys.unspam
        case .trash:    return Keys.trash
        case .untrash:  return Keys.untrash
        }
    }

    /// Returns the localized text version of the Enum
    ///
    public var description: String {
        switch self {
        case .approved:
            return NSLocalizedString("Approved", comment: "Display label for the review's approved status")
        case .hold:
            return NSLocalizedString("Pending", comment: "Display label for the review's pending status")
        case .spam:
            return NSLocalizedString("Spam", comment: "Display label for the review's spam status")
        case .unspam:
            return NSLocalizedString("Unspam", comment: "Display label for the review's unspam status")
        case .trash:
            return NSLocalizedString("Trash", comment: "Display label for the review's trash status")
        case .untrash:
            return NSLocalizedString("Untrash", comment: "Display label for the review's untrash status")
        }
    }
}


/// Enum containing the 'Known' ProductReviewStatus Keys
///
private enum Keys {
    static let approved = "approved"
    static let hold     = "hold"
    static let spam     = "spam"
    static let unspam   = "unspam"
    static let trash    = "trash"
    static let untrash  = "untrash"
}
