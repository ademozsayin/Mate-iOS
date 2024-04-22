//
//  BottomSheetProductType.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation
import FiableRedux
import UIKit

/// Represents the product types available when creating or editing products.
/// This includes the remote `ProductType`, whether the product type is virtual, and strings/images shown in the bottom sheet.
///
public enum BottomSheetProductType: Hashable, Identifiable {

    case football
    case basketball
    case tenins

    public var id: Int {
        switch self {
        case .football:
            return 1
        case .basketball:
            return 2
        case .tenins:
            return 3
        }
    }

    /// Remote ProductType
    ///
    var productType: MateCategory {
        
        switch self.id {
        case 1:
            return MateCategory(id: 1, name: "Football", createdAt: nil, updatedAt: nil)
        case 2:
            return MateCategory(id: 2, name: "Football", createdAt: nil, updatedAt: nil)
        case 3:
            return MateCategory(id: 3, name: "Football", createdAt: nil, updatedAt: nil)
        default:
            return MateCategory(id: 1, name: "Football", createdAt: nil, updatedAt: nil)
        }
    }



    /// Title shown on the action sheet.
    ///
    var actionSheetTitle: String {
        switch self {
  
        case .football:
            return NSLocalizedString(
                "bottomSheetProductType.variable.title",
                value: "Variable product",
                comment: "Action sheet option when the user wants to change the Product type to varible product")
        case .basketball:
            return NSLocalizedString(
                "bottomSheetProductType.grouped.title",
                value: "Grouped product",
                comment: "Action sheet option when the user wants to change the Product type to grouped product")
        case .tenins:
            return NSLocalizedString(
                "bottomSheetProductType.affiliate.title",
                value: "External product",
                comment: "Action sheet option when the user wants to change the Product type to external product")
    
        }
    }

    /// Description shown on the action sheet.
    ///
    var actionSheetDescription: String {
        switch self {
     
        case .football:
            return NSLocalizedString(
                "bottomSheetProductType.variable.description",
                value: "A product with variations like color or size",
                comment: "Description of the Action sheet option when the user wants to change the Product type to variable product")
        case .basketball:
            return NSLocalizedString(
                "bottomSheetProductType.grouped.description",
                value: "A collection of related products",
                comment: "Description of the Action sheet option when the user wants to change the Product type to grouped product")
        case .tenins:
            return NSLocalizedString(
                "bottomSheetProductType.affiliate.description",
                value: "Link a product to an external website",
                comment: "Description of the Action sheet option when the user wants to change the Product type to external product")
        }
    }

    /// Image shown on the action sheet.
    ///
    var actionSheetImage: UIImage {
        
        switch self {
        case .football:
            return UIImage.cloudOutlineImage
        case .basketball:
            return UIImage.cloudOutlineImage
        case .tenins:
            return UIImage.productImage
        }
        
    }

//    init(productType: MateCategory, isVirtual: Bool) {
//        
//        switch productType.id {
//        case 1:
//            self = .football
//        case 2:
//            self = .basketball
//        case 3:
//            self = .tenins
//        default:
//            break
//        }
//        
////        super.init(productType: productType, isVirtual: false)
//    }
}
