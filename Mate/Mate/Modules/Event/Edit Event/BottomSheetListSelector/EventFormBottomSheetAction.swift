//
//  EventFormBottomSheetAction.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import Foundation
import FiableRedux

/// Actions in the event form bottom sheet to add more product details.
enum EventFormBottomSheetAction {
   
    case editCategories
    

    init?(productFormAction: EventFormEditAction) {
        switch productFormAction {
        case .categories:
            self = .editCategories
        default:
            return nil
        }
    }
}

extension EventFormBottomSheetAction {
    var title: String {
        switch self {
      
        case .editCategories:
            return NSLocalizedString("Categories",
                                     comment: "Title of the product form bottom sheet action for")
        }
    }

    var subtitle: String {
        switch self {

        case .editCategories:
            return NSLocalizedString("Organise your products into related groups",
                                     comment: "Subtitle of the product form bottom sheet action for")
        }
    }
}
