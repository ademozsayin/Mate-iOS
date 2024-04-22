import Foundation
import FiableRedux
import MateNetworking

// MARK: ViewModel Builder
extension ProductCategoryListViewModel {

    /// Creates `ProductCategoryCellViewModel` types
    ///
    struct CellViewModelBuilder {

        /// Represents Categories -> SubCategories relatioships
        ///
        private struct CategoryTree {

            /// Stores categories by holding a reference to it's `parentID`
            ///
            private let nodes: [Int64: [MateCategory]]

            init(categories: [MateCategory]) {
                nodes = [:]// Self.nodesFromCategories(categories)
            }

            /// Returns a dictionary  where each key holds a category `parentID` each value an array of subcategories.
            ///
//            private static func nodesFromCategories(_ productCategories: [MateCategory]) -> [Int64: [MateCategory]] {
//                return productCategories.reduce(into: [Int64: [MateCategory]]) { (result, category) in
//                    var children = result[Int64(category.id)] ?? []
//                    children.append(category)
//                    result[Int64(category.id)] = children
//                }
//            }

            /// Returns categories that don't have a `parentID`
            ///
            var rootCategories: [MateCategory] {
                return []//nodes[Int64(MateCategory.id)] ?? []
            }

            /// Returns the inmediate subCategories of a given category or `nil` if there aren't any.
            ///
            func outterSubCategories(of category: MateCategory) -> [MateCategory]? {
                return nodes[Int64(category.id)]
            }
        }

        /// Returns a simple array of `ProductCategoryCellViewModel` from the provided `categories` disregarding the parent-child relationships.
        /// Provide an array of `selectedCategories` to properly reflect the selected state in the returned view model array.
        ///
        static func flatViewModels(from categories: [MateCategory], selectedCategories: [MateCategory]) -> [ProductCategoryCellViewModel] {
            categories.map { category in
                viewModel(for: category, selectedCategories: selectedCategories, indentationLevel: 0)
            }
        }

        /// Returns an array of `ProductCategoryCellViewModel` by sorting the provided `categories` following a `Category -> SubCategory` order.
        /// Provide an array of `selectedCategories` to properly reflect the selected state in the returned view model array.
        ///
        static func viewModels(from categories: [MateCategory], selectedCategories: [MateCategory]) -> [ProductCategoryCellViewModel] {
            // Create tree structure
            let tree = CategoryTree(categories: categories)

            // For each root category, get all sub-categories and return a flattened array of view models
            let viewModels = tree.rootCategories.flatMap { category -> [ProductCategoryCellViewModel] in
                return flattenViewModels(of: category, in: tree, selectedCategories: selectedCategories)
            }

            return viewModels
        }

        /// Recursively return all sub-categories view models of a given category in a given tree.
        /// Provide an array of `selectedCategories` to properly reflect the selected state in the returned view model array.
        ///
        private static func flattenViewModels(of category: MateCategory,
                                              in tree: CategoryTree,
                                              selectedCategories: [MateCategory],
                                              depthLevel: Int = 0) -> [ProductCategoryCellViewModel] {

            // View model for the main category
            let categoryViewModel = viewModel(for: category, selectedCategories: selectedCategories, indentationLevel: depthLevel)

            // Base case, return the single view model when a category doesn't have any sub-categories
            guard let outterSubCategories = tree.outterSubCategories(of: category) else {
                return [categoryViewModel]
            }

            // Return the main categoryViewModel + all possible sub-categories VMs by calling this function recursively
            return [categoryViewModel] + outterSubCategories.flatMap { outterSubCategory -> [ProductCategoryCellViewModel] in

                // Increase the `depthLevel` to properly track the view model indentation level
                return flattenViewModels(of: outterSubCategory, in: tree, selectedCategories: selectedCategories, depthLevel: depthLevel + 1)
            }
        }

        /// Return a view model for an specific category, indentation level and `selectedCategories` array
        ///
        private static func viewModel(for category: MateCategory,
                                      selectedCategories: [MateCategory],
                                      indentationLevel: Int) -> ProductCategoryCellViewModel {
            let isSelected = selectedCategories.contains(category)
            return ProductCategoryCellViewModel(categoryID: Int64(category.id),
                                                name: category.name,
                                                isSelected: isSelected,
                                                indentationLevel: indentationLevel)
        }
    }
}
