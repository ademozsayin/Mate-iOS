//
//  EventCategoryAction.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import MateNetworking

/// ProductCategoryAction: Defines all of the Actions supported by the ProductCategoryStore.
///
public enum EventCategoryAction: Action {

    /// Synchronizes all ProductCategories matching the specified criteria.
    /// `onCompletion` will be invoked when the sync operation finishes. `error` will be nil if the operation succeed.
    ///
    case synchronizeProductCategories(fromPageNumber: Int, onCompletion:(Result<[MateCategory], Error>) -> Void)


    /// Synchronizes the ProductCategory matching the specified categoryID.
    /// `onCompletion` will be invoked when the sync operation finishes. `error` will be nil if the operation succeed.
    ///
    case synchronizeProductCategory(categoryID: Int64, onCompletion: (Result<MateCategory, Error>) -> Void)


}

/// Defines all errors that a `ProductCategoryAction` can return
///
public enum EventCategoryActionError: Error {
    /// Represents a product category synchronization failed state
    ///
    case categoriesSynchronization(pageNumber: Int, rawError: Error)

    /// The requested category cannot be found remotely
    ///
    case categoryDoesNotExistRemotely
}
