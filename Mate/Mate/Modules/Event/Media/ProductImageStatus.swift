//
//  ProductImageStatus.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Photos
import FiableRedux
import UIKit
/// The status of a Product image.
///
enum ProductImageStatus: Equatable {
    /// An image asset is being uploaded.
    ///
    case uploading(asset: ProductImageAssetType)

    /// The Product image exists remotely.
    ///
    case remote(image: ProductImage)
}

/// The type of product image asset.
enum ProductImageAssetType: Equatable {
    /// `PHAsset` from device photo library or camera capture.
    case phAsset(asset: PHAsset)

    /// `UIImage` from image processing. The filename and alt text need to be provided separately.
    case uiImage(image: UIImage, filename: String?, altText: String?)
}

extension Collection where Element == ProductImageStatus {
    var images: [ProductImage] {
        compactMap { status in
            switch status {
            case .remote(let productImage):
                return productImage
            default:
                return nil
            }
        }
    }

    /// Whether there are still any images being uploaded.
    ///
    var hasPendingUpload: Bool {
        return contains(where: {
            switch $0 {
            case .uploading:
                return true
            default:
                return false
            }
        })
    }
}

extension ProductImageStatus {
    var cellReuseIdentifier: String {
        return cellClass.reuseIdentifier
    }

    private var cellClass: UICollectionViewCell.Type {
        switch self {
        case .uploading:
            return InProgressProductImageCollectionViewCell.self
        case .remote:
            return ProductImageCollectionViewCell.self
        }
    }

    /// A string that uniquely identifies a `ProductImageStatus` during
    /// dragging.
    ///
    var dragItemIdentifier: String {
        switch self {
        case .uploading(let asset):
            switch asset {
                case let .phAsset(asset):
                    return "asset.identifier()"
                case .uiImage:
                    return UUID().uuidString
            }
        case .remote(let image):
            return "\(image.imageID)"
        }
    }
}


public struct ProductImage: Codable, Equatable {
    public let imageID: Int64
    public let dateCreated: Date    // gmt
    public let dateModified: Date?  // gmt
    public let src: String
    public let name: String?
    public let alt: String?

    /// ProductImage initializer.
    ///
    public init(imageID: Int64,
                dateCreated: Date,
                dateModified: Date?,
                src: String,
                name: String?,
                alt: String?) {
        self.imageID = imageID
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.src = src
        self.name = name
        self.alt = alt
    }

    /// Public initializer for ProductImage
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let imageID = try container.decode(Int64.self, forKey: .imageID)
        let dateCreated = (try? container.decodeIfPresent(Date.self, forKey: .dateCreated)) ?? Date()
        let dateModified = try? container.decodeIfPresent(Date.self, forKey: .dateModified)
        let src = try container.decode(String.self, forKey: .src)
        let name = try container.decodeIfPresent(String.self, forKey: .name)
        let alt: String? = {
            do {
                return try container.decodeIfPresent(String.self, forKey: .alt)
            } catch {
                DDLogError("⛔️ Error parsing `alt` for ProductImage ID \(imageID): \(error)")
                return nil
            }
        }()

        self.init(imageID: imageID,
                  dateCreated: dateCreated,
                  dateModified: dateModified,
                  src: src,
                  name: name,
                  alt: alt)
    }
}


/// Defines all the ProductImage CodingKeys.
///
private extension ProductImage {
    enum CodingKeys: String, CodingKey {
        case imageID        = "id"
        case dateCreated    = "date_created_gmt"
        case dateModified   = "date_modified_gmt"
        case src            = "src"
        case name           = "name"
        case alt            = "alt"
    }
}



/// UICollectionViewCell Helpers
///
extension UICollectionViewCell {

    /// Returns a reuseIdentifier that matches the receiver's classname (non namespaced).
    ///
    class var reuseIdentifier: String {
        return classNameWithoutNamespaces
    }

    /// Applies the default background color
    ///
    func applyDefaultBackgroundStyle() {
        backgroundColor = .listForeground(modal: false)
        contentView.backgroundColor = .listForeground(modal: false)
    }

    func applyGrayBackgroundStyle() {
        backgroundColor = .systemColor(.secondarySystemGroupedBackground)
    }
}
