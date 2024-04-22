//
//  FilterProductListViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import UIKit
import FiableRedux
import FiableFoundation
import MateStorage
import MateNetworking

/// `FilterListViewModel` for filtering a list of products.
final class FilterProductListViewModel: EventListViewModel {
    typealias Criteria = Filters

    /// Aggregates the filter values that can be updated in the Filter Products UI.
    struct Filters: Equatable {
        let productCategory: MateCategory?

        let numberOfActiveFilters: Int

        init() {
            productCategory = nil
            numberOfActiveFilters = 0
        }

        init(
            productCategory: MateCategory?,
            numberOfActiveFilters: Int
        ) {
            self.productCategory = productCategory
            self.numberOfActiveFilters = numberOfActiveFilters
        }

        // Generate a string based on populated filters, like "instock,publish,simple,clothes"
        var analyticsDescription: String {
            let elements: [String?] = [
                productCategory?.name
            ]
            return elements.compactMap { $0 }.joined(separator: ",")
        }
    }

    let filterActionTitle = NSLocalizedString(
        "Show Products",
        comment: "Button title for applying filters to a list of products."
    )

    let filterTypeViewModels: [FilterTypeViewModel]

    private let productCategoryFilterViewModel: FilterTypeViewModel

    /// - Parameters:
    ///   - filters: the filters to be applied initially.
    init(
        filters: Filters
    ) {

        self.productCategoryFilterViewModel = ProductListFilter.productCategory.createViewModel(filters: filters)

        self.filterTypeViewModels = [
            productCategoryFilterViewModel
        ]
    }

    var criteria: Filters {
        let productCategory = productCategoryFilterViewModel.selectedValue as? MateCategory ?? nil

        let numberOfActiveFilters = filterTypeViewModels.numberOfActiveFilters

        return Filters(
            productCategory: productCategory,
            numberOfActiveFilters: numberOfActiveFilters
        )
    }

    func clearAll() {
        let clearedProductCategory: MateCategory? = nil
        productCategoryFilterViewModel.selectedValue = clearedProductCategory as! any FilterType
    }
}

extension FilterProductListViewModel {
    /// Rows listed in the order they appear on screen
    ///
    enum ProductListFilter {
        case productCategory
    }
}

private extension FilterProductListViewModel.ProductListFilter {
    var title: String {
        switch self {
        case .productCategory:
            return NSLocalizedString("Product Category", comment: "Row title for filtering products by product category.")
        }
    }
}

extension FilterProductListViewModel.ProductListFilter {
    func createViewModel(filters: FilterProductListViewModel.Filters,
                         storageManager: StorageManagerType = ServiceLocator.storageManager) -> FilterTypeViewModel {
        switch self {
        case let .productCategory:
            return FilterTypeViewModel(title: title,
                                       listSelectorConfig: .productCategories,
                                       selectedValue: filters.productCategory as! FilterType)
        }
    }

}
