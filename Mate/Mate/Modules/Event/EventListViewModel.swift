//
//  EventListViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation
import FiableRedux
import SwiftUI
import MateNetworking

protocol ProductsListViewModelProtocol { }

/// View model for `ProductsViewController`. Has stores logic related to Bulk Editing and Woo Subscriptions.
///
@Observable class EventListViewModel: ProductsListViewModelProtocol {

    enum BulkEditError: Error {
        case noProductsSelected
    }

    private let stores: StoresManager

    private(set) var selectedProducts: Set<MateEvent> = .init()

    private let featureFlagService: FeatureFlagService

    var userEvent:[UserEvent] = []
    var onDataLoadingError: ((Error?) -> Void)?
    
    init(
         stores: StoresManager = ServiceLocator.stores,
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService
    ) {
        self.stores = stores
        self.featureFlagService = featureFlagService
    }

    var selectedProductsCount: Int {
        selectedProducts.count
    }

    var bulkEditActionIsEnabled: Bool {
        !selectedProducts.isEmpty
    }

    func productIsSelected(_ productToCheck: MateEvent) -> Bool {
        return selectedProducts.contains(productToCheck)
    }

    func selectProduct(_ product: MateEvent) {
        selectedProducts.insert(product)
    }

    func selectProducts(_ products: [MateEvent]) {
        selectedProducts.formUnion(products)
    }

    func deselectProduct(_ product: MateEvent) {
        selectedProducts.remove(product)
    }

    func deselectAll() {
        selectedProducts.removeAll()
    }

    /// Represents if a property in a collection of `Product`  has the same value or different values or is missing.
    ///
    enum BulkValue: Equatable {
        /// All variations have the same value
        case value(String)
        /// When variations have mixed values.
        case mixed
        /// None of the variation has a value
        case none
    }
}
