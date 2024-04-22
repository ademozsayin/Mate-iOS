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
            return MateCategory(id: 2, name: "Basketball", createdAt: nil, updatedAt: nil)
        case 3:
            return MateCategory(id: 3, name: "Tennis", createdAt: nil, updatedAt: nil)
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
                "Football",
                value: "Football",
                comment: "Action sheet option when the user wants to change the Product type to varible product")
        case .basketball:
            return NSLocalizedString(
                "Basketball",
                value: "Basketball",
                comment: "Action sheet option when the user wants to change the Product type to grouped product")
        case .tenins:
            return NSLocalizedString(
                "Tennis",
                value: "Tennis",
                comment: "Action sheet option when the user wants to change the Product type to external product")
    
        }
    }

    /// Description shown on the action sheet.
    ///
    var actionSheetDescription: String {
        switch self {
     
        case .football:
            return NSLocalizedString(
                "If you're setting up a football form, the default maximum capacity is 12 players. Feel free to modify this value to suit your requirements before proceeding.",
                comment: "Description of the Action sheet option when the user wants to change the Product type to variable product")
        case .basketball:
            return NSLocalizedString(
                "For basketball forms, the default maximum number of players is 10, but you can adjust this value as needed before creating the form",
                comment: "Description of the Action sheet option when the user wants to change the Product type to grouped product")
        case .tenins:
            return NSLocalizedString(
                "When choosing tennis, the default setting is for 2 players.",
                comment: "Description of the Action sheet option when the user wants to change the Product type to external product")
        }
    }

    /// Image shown on the action sheet.
    ///
    var actionSheetImage: UIImage {
        
        switch self {
        case .football:
            return UIImage.init(systemName: "soccerball")!
        case .basketball:
            return UIImage.init(systemName: "basketball")!
        case .tenins:
            return UIImage.init(systemName: "tennisball")!
        }
        
    }

}
