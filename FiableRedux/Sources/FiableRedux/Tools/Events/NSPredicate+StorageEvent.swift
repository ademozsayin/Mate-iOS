//
//  File.swift
//  
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation


extension NSPredicate {
    public static func createProductPredicate(productType: Int? = nil) -> NSPredicate {

   
        let productTypePredicate = productType.flatMap { productType -> NSPredicate? in
            let key = #selector(getter: StorageEvent.categoryID)
            return NSPredicate(format: "\(key) == %@", productType )
        }

        let subpredicates = [productTypePredicate].compactMap({ $0 })

        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }
}

extension ResultsController where T: StorageEvent {
    public func updatePredicate( productType: Int? = nil) {
        self.predicate = NSPredicate.createProductPredicate( productType: productType)
    }
}
