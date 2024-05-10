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
    
    private let defaults: UserDefaults
    
    init(
         stores: StoresManager = ServiceLocator.stores,
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService,
         defaults: UserDefaults
    ) {
        self.stores = stores
        self.featureFlagService = featureFlagService
        self.defaults = defaults
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

///
/// Check if sync is necessary
///
extension EventListViewModel {
    final func isSyncRequired() async -> Bool {
        return lastSyncIfBiggerThan60Second()
    }
    
    final func setLastSyncTime() {
        defaults[.userEventsLastSyncDate] = Date()
    }
    
    final func clearSyncDateAfterEventCreation() {
        defaults[.userEventsLastSyncDate] = nil
    }
    
    final func lastSyncIfBiggerThan60Second() -> Bool {
        guard let lastSyncDate = defaults[.userEventsLastSyncDate] as? Date else {
            DDLogInfo(" ✅ No last sync time recorded or wrong data type.")
            return true // Assume sync is needed if no valid date is stored
        }
        let timeSinceLastSync = Date().timeIntervalSince(lastSyncDate)
        DDLogInfo("  ✅Time since last sync: \(timeSinceLastSync) seconds")
        return timeSinceLastSync > 60
    }
}
