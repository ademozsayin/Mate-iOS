//
//  ProductCategoryListViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Combine
import Foundation
import FiableRedux
import protocol MateStorage.StorageManagerType

/// Classes conforming to this protocol can enrich the Product Category List UI,
/// e.g by adding extra rows
///
protocol ProductCategoryListViewModelEnrichingDataSource: AnyObject {
    /// This method enriches the passed view models array so the case logic specific view models can be added
    ///
    func enrichCategoryViewModels(_ viewModels: [ProductCategoryCellViewModel]) -> [ProductCategoryCellViewModel]
}

/// Classes conforming to this protocol are notified of relevant events
///
protocol ProductCategoryListViewModelDelegate: AnyObject {
    /// Called when a row is selected
    ///
    func viewModel(_ viewModel: ProductCategoryListViewModel, didSelectRowAt index: Int)
}

/// Manages the presentation of a `ProductCategoryListView`, taking care of fetching, syncing, and providing the category view models for each cell
///
final class ProductCategoryListViewModel {

    /// Obscure token that allows the view model to retry the synchronizeCategories operation
    ///
    struct RetryToken: Equatable {
        fileprivate let fromPageNumber: Int
    }

    /// Represents the current state of `synchronizeCategories` action. Useful for the consumer to update it's UI upon changes
    ///
    enum SyncingState: Equatable {
        case initialized
        case syncing
        case failed(RetryToken)
        case synced
    }

    /// Reference to the StoresManager to dispatch Yosemite Actions.
    ///
    private let storesManager: StoresManager

    /// Storage to fetch categories from.
    ///
    private let storageManager: StorageManagerType


    /// Initially selected category IDs.
    /// This is mutable so that we can remove any item when unselecting it manually.
    ///
    private var initiallySelectedID: Int64?

    /// Product categories that will be eventually modified by the user
    ///
    @Published private(set) var selectedCategory: MateCategory?

    /// Search query from the search bar
    ///
    @Published var searchQuery: String = ""

    private var searchQuerySubscription: AnyCancellable?

    /// Array of view models to be rendered by the View Controller.
    ///
    @Published private(set) var categoryViewModels: [ProductCategoryCellViewModel] = []

    /// Closure invoked when the list needs to reload
    ///
    private var onReloadNeeded: (() -> Void)?

    /// Delegate to be notified of meaningful events
    ///
    private weak var delegate: ProductCategoryListViewModelDelegate?

    /// Enriches product category cells view models
    ///
    private weak var enrichingDataSource: ProductCategoryListViewModelEnrichingDataSource?

    /// Callback when a product category is selected. Passing nil means all categories are deselected
    ///
    typealias ProductCategorySelection = (MateCategory?) -> Void
    private var onProductCategorySelection: ProductCategorySelection?

    /// Current  category synchronization state
    ///
    @Published private(set) var syncCategoriesState: SyncingState = .initialized

    
    private lazy var resultController: ResultsController<StorageEventCategory> = {
        let descriptor = NSSortDescriptor(keyPath: \StorageEventCategory.name, ascending: true)
        return ResultsController<StorageEventCategory>(storageManager: storageManager, matching: nil, sortedBy: [descriptor])
    }()

    init(
         selectedCategoryID: Int64,
         selectedCategory: MateCategory?,
         storesManager: StoresManager = ServiceLocator.stores,
         storageManager: StorageManagerType = ServiceLocator.storageManager,
         enrichingDataSource: ProductCategoryListViewModelEnrichingDataSource? = nil,
         delegate: ProductCategoryListViewModelDelegate? = nil,
         onProductCategorySelection: ProductCategorySelection? = nil) {
        self.storesManager = storesManager
        self.storageManager = storageManager
        self.selectedCategory = selectedCategory
        self.enrichingDataSource = enrichingDataSource
        self.delegate = delegate
        self.onProductCategorySelection = onProductCategorySelection
        self.initiallySelectedID = selectedCategoryID

        try? resultController.performFetch()
        updateViewModelsArray()
        configureProductSearch()
    }

    /// Load existing categories from storage and fire the synchronize all categories action.
    ///
    func performFetch() {
        Task {
            try await synchronizeAllCategories()
        }
       
    }

    /// Retry product categories synchronization when `syncCategoriesState` is on a `.failed` state.
    ///
    func retryCategorySynchronization(retryToken: RetryToken) {
        guard syncCategoriesState == .failed(retryToken) else {
            return
        }
       
        Task {
            try await synchronizeAllCategories(fromPageNumber: retryToken.fromPageNumber)
        }
    }

    /// Observe the need of reload by passing a closure that will be invoked when there is a need to reload the data.
    /// Calling this method will remove any other previous observer.
    ///
    func observeReloadNeeded(onReloadNeeded: @escaping () -> Void) {
        self.onReloadNeeded = onReloadNeeded
    }

    /// The invokation of this method will trigger a reload of the list without performing any new fetch,
    /// neither local or remote.
    ///
    func reloadData() {
        onReloadNeeded?()
    }

    func findCategory(with id: Int64) -> MateCategory? {
        return resultController.fetchedObjects.first(where: { $0.id == id })
    }

    /// Add a new category added remotely, that will be selected
    ///
    func addAndSelectNewCategory(category: MateCategory) {
  
    }

    /// Resets the selected categories. This method does not trigger any UI reload
    ///
    func resetSelectedCategories() {
        selectedCategory = nil
    }

    /// Resets the selected categories and triggers UI reload
    ///
    func resetSelectedCategoriesAndReload() {
        initiallySelectedID = nil
        resetSelectedCategories()
        updateViewModelsArray()
        reloadData()
    }

    /// Select or Deselect a category, notifying the delegate before any other action
    ///
    func selectOrDeselectCategory(index: Int) {
        delegate?.viewModel(self, didSelectRowAt: index)

        guard let categoryViewModel = categoryViewModels[safe: index] else {
            return
        }

        let selectedCategory = resultController.fetchedObjects.first(where: { $0.id == categoryViewModel.categoryID! })
        self.selectedCategory = selectedCategory
        onProductCategorySelection?(selectedCategory)

        updateViewModelsArray()
    }

    /// Updates  `categoryViewModels` from  the resultController's fetched objects,
    /// letting the enriching data source enrich the view models array if necessary.
    ///
    func updateViewModelsArray() {
        let fetchedCategories = resultController.fetchedObjects
        updateInitialItemsIfNeeded(with: fetchedCategories)
        let baseViewModels: [ProductCategoryCellViewModel]
        baseViewModels = ProductCategoryListViewModel.CellViewModelBuilder.flatViewModels(
            from: fetchedCategories,
            selectedCategory: selectedCategory
        )

        categoryViewModels = enrichingDataSource?.enrichCategoryViewModels(baseViewModels) ?? baseViewModels
    }

    /// Update `selectedCategories` based on initially selected items.
    ///
    private func updateInitialItemsIfNeeded(with categories: [MateCategory]) {
        guard initiallySelectedID == nil && selectedCategory == nil else {
            return
        }
        
        selectedCategory = categories.first(where: { $0.id == initiallySelectedID ?? 1})
    }

    /// Updates the category results predicate & reload the list
    ///
    private func configureProductSearch() {
    }
}

// MARK: - Synchronize Categories
//
private extension ProductCategoryListViewModel {

    
    @MainActor
    func synchronizeAllCategories(fromPageNumber: Int = Default.firstPageNumber) async throws {
        try await withCheckedThrowingContinuation { continuation in
            storesManager.dispatch(EventCategoryAction.synchronizeProductCategories(fromPageNumber: Default.firstPageNumber,
                                                                               onCompletion: { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let data):
                    self.updateViewModelsArray()
                    self.syncCategoriesState = .synced
                    
                case .failure(let err):
                    self.handleSychronizeAllCategoriesError(err as! EventCategoryActionError)
                }
                continuation.resume()
            }))
        }
    }

    /// Update `syncCategoriesState` with the proper retryToken
    ///
    func handleSychronizeAllCategoriesError(_ error: EventCategoryActionError) {
        switch error {
        case let .categoriesSynchronization(pageNumber, rawError):
            let retryToken = RetryToken(fromPageNumber: pageNumber)
            syncCategoriesState = .failed(retryToken)
            DDLogError("⛔️ Error fetching product categories: \(rawError.localizedDescription)")
        default:
            break
        }
    }
}


// MARK: - Constants
//
private extension ProductCategoryListViewModel {
    enum Default {
        public static let firstPageNumber = 1
    }
}


// MARK: ViewModel Builder
extension ProductCategoryListViewModel {

    /// Creates `ProductCategoryCellViewModel` types
    ///
    struct CellViewModelBuilder {

        /// Returns a simple array of `ProductCategoryCellViewModel` from the provided `categories` disregarding the parent-child relationships.
        /// Provide an array of `selectedCategories` to properly reflect the selected state in the returned view model array.
        ///
        static func flatViewModels(from categories: [MateCategory],
                                   selectedCategory: MateCategory?
        ) -> [ProductCategoryCellViewModel] {
            categories.map { category in
                viewModel(for: category, selectedCategory: selectedCategory, indentationLevel: 0)
            }
        }
        /// Provide an array of `selectedCategories` to properly reflect the selected state in the returned view model array.
    

        /// Return a view model for an specific category, indentation level and `selectedCategories` array
        ///
        private static func viewModel(for category: MateCategory,
                                      selectedCategory: MateCategory?,
                                      indentationLevel: Int) -> ProductCategoryCellViewModel {
            var isSelected = false
            if selectedCategory == category {
                isSelected = true
            }
            return ProductCategoryCellViewModel(categoryID: Int64(category.id),
                                                name: category.name,
                                                isSelected: isSelected,
                                                indentationLevel: indentationLevel)
        }
    }
}
