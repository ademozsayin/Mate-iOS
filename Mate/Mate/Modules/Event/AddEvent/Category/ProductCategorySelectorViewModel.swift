//
//  ProductCategorySelectorViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import protocol MateStorage.StorageManagerType
import FiableRedux

/// View model for `ProductCategorySelector`.
///
final class ProductCategorySelectorViewModel: ObservableObject {
    private let onCategorySelection: (MateCategory) -> Void
    private var selectedCategoryId: Int64
    private let stores: StoresManager
    private let storageManager: StorageManagerType

    /// View model for the category list.
    ///
    let listViewModel: ProductCategoryListViewModel

    @Published private(set) var selectedItemsCount: Int = 0

    init(
        selectedCategory: Int64,
        storesManager: StoresManager = ServiceLocator.stores,
        storageManager: StorageManagerType = ServiceLocator.storageManager,
        onCategorySelection: @escaping (MateCategory) -> Void
    ) {
        self.selectedCategoryId = selectedCategory
        self.onCategorySelection = onCategorySelection
        self.stores = storesManager
        self.storageManager = storageManager

        listViewModel = .init(
            selectedCategoryID: selectedCategoryId, 
            selectedCategory: nil,
            storesManager: stores,
            storageManager: storageManager)
//        listViewModel.$selectedCategory
//            .map { $0 }
//            .assign(to: &$selectedItemsCount)
    }

    /// Triggered when selection is done.
    ///
    func submitSelection() {
        guard let selectedCategory = listViewModel.selectedCategory else {
            return
        }
        onCategorySelection(selectedCategory)
    }
}
