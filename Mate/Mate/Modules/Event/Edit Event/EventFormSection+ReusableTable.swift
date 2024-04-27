//
//  EventFormSection+ReusableTable.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import UIKit

extension EventFormSection {
    func reuseIdentifier(at rowIndex: Int) -> String {
        switch self {
        case .primaryFields(let rows):
            let row = rows[rowIndex]
            return row.reuseIdentifier
        case .settings(let rows):
            let row = rows[rowIndex]
            return row.reuseIdentifier
        }
    }
}

/// Represents a row in a table.
protocol ReusableTableRow {
    var reuseIdentifier: String { get }

    /// A table row could be presented by different `UITableViewCell` types, depending on the state.
    var cellTypes: [UITableViewCell.Type] { get }
}


extension EventFormSection.PrimaryFieldRow: ReusableTableRow {
    var cellTypes: [UITableViewCell.Type] {
        switch self {
      
        case .name:
            return [LabeledTextViewTableViewCell.self, BasicTableViewCell.self]
        case .variationName:
            return [cellType]
        case .description:
            return [ImageAndTitleAndTextTableViewCell.self, BasicTableViewCell.self]
        default:
            return [LabeledTextViewTableViewCell.self, BasicTableViewCell.self]
        }
    }

    var reuseIdentifier: String {
        return cellType.reuseIdentifier
    }

    private var cellType: UITableViewCell.Type {
        switch self {
        case .name(_, let editable, _):
            return editable ? LabeledTextViewTableViewCell.self: BasicTableViewCell.self
        case .variationName:
            return BasicTableViewCell.self
        case .description(let description, _, _):
            return description?.isEmpty == false ? ImageAndTitleAndTextTableViewCell.self: BasicTableViewCell.self
        case .separator:
            return BasicTableViewCell.self
        }
    }
}

extension EventFormSection.SettingsRow: ReusableTableRow {
    var cellTypes: [UITableViewCell.Type] {
        switch self {
        case .price,
             .productType,
             .inventory,
             .shipping,
             .addOns,
             .categories,
             .tags,
             .shortDescription,
             .externalURL,
             .sku,
             .groupedProducts,
             .variations,
             .downloadableFiles,
             .linkedProducts,
             .status,
             .noPriceWarning,
             .attributes,
             .bundledProducts,
             .components,
             .subscriptionFreeTrial,
             .subscriptionExpiry,
             .noVariationsWarning,
             .quantityRules:
            return [ImageAndTitleAndTextTableViewCell.self]
        case .reviews:
            return [ProductReviewsTableViewCell.self]
        }
    }

    var reuseIdentifier: String {
        return cellType.reuseIdentifier
    }

    private var cellType: UITableViewCell.Type {
        switch self {
        case .price,
             .productType,
             .inventory,
             .shipping,
             .addOns,
             .categories,
             .tags,
             .shortDescription,
             .externalURL,
             .sku,
             .groupedProducts,
             .variations,
             .downloadableFiles,
             .linkedProducts,
             .status,
             .noPriceWarning,
             .attributes,
             .bundledProducts,
             .components,
             .subscriptionFreeTrial,
             .subscriptionExpiry,
             .noVariationsWarning,
             .quantityRules:
            return ImageAndTitleAndTextTableViewCell.self
        case .reviews:
            return ProductReviewsTableViewCell.self
        }
    }
}
