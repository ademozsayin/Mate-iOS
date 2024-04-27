//
//  EditableEventModel.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import Foundation
import FiableRedux

/// Represents an editable data model based on `Product`.
final class EditableEventModel {
    let product: MateEvent

    init(product: MateEvent) {
        self.product = product
    }
}

extension EditableEventModel: EventFormDataModel {
    var eventId: Int64 {
        Int64(product.id)
    }
    
    var name: String {
        product.name ?? ""
    }
    
    var google_place_id: String {
        ""
    }
    
    var startTime: String? {
        product.startTime ?? ""
    }
    
    var productType: FiableRedux.MateCategory? {
        product.category
    }
    
    var maximumAttendees: String? {
        product.maxAttendees
    }
    
    var existsRemotely: Bool {
        eventId != 0
    }
    
    var status: EventStatus? {
        product.status
    }
    

    /// Helper to determine if a product model is empty.
    /// We consider it as empty if its underlying product matches the `ProductFactory.createNewProduct` output.
    /// Additionally we don't take dates into consideration as we don't control their value when creating a product.
    ///
//    func isEmpty() -> Bool {
//        guard let emptyProduct = ProductFactory().createNewProduct(type: productType,
//                                                                   isVirtual: virtual,
//                                                                   siteID: siteID) else {
//            return false
//        }
//
//        let commonDate = Date()
//        return emptyProduct.copy(date: commonDate, dateCreated: commonDate, dateModified: commonDate, dateOnSaleStart: commonDate, dateOnSaleEnd: commonDate) ==
//               product.copy(date: commonDate, dateCreated: commonDate, dateModified: commonDate, dateOnSaleStart: commonDate, dateOnSaleEnd: commonDate)
//    }
}

extension EditableEventModel: Equatable {
    static func ==(lhs: EditableEventModel, rhs: EditableEventModel) -> Bool {
        return lhs.product == rhs.product
    }
}
