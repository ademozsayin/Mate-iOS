import Foundation
import protocol MateStorage.StorageManagerType
import FiableRedux
import MateNetworking

/// View model for `ProductCategorySelector`.
///
final class ProductCategorySelectorViewModel: ObservableObject {
    private let siteID: Int64
    private let onCategorySelection: ([MateCategory]) -> Void
    private var selectedCategories: [Int64]
    private let stores: StoresManager
    private let storageManager: StorageManagerType

    /// View model for the category list.
    ///
    let listViewModel: ProductCategoryListViewModel

    @Published private(set) var selectedItemsCount: Int = 0

    init(siteID: Int64,
         selectedCategories: [Int64] = [],
         storesManager: StoresManager = ServiceLocator.stores,
         storageManager: StorageManagerType = ServiceLocator.storageManager,
         onCategorySelection: @escaping ([MateCategory]) -> Void) {
        self.siteID = siteID
        self.selectedCategories = selectedCategories
        self.onCategorySelection = onCategorySelection
        self.stores = storesManager
        self.storageManager = storageManager

        listViewModel = .init(
                              selectedCategoryIDs: selectedCategories,
                              storesManager: stores,
                              storageManager: storageManager)
        listViewModel.$selectedCategories
            .map { $0.count }
            .assign(to: &$selectedItemsCount)
    }

    /// Triggered when selection is done.
    ///
    func submitSelection() {
        onCategorySelection(listViewModel.selectedCategories)
    }
}
