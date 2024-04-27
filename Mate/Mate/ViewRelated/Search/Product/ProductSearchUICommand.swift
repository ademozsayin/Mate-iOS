import UIKit
import FiableRedux
import MateNetworking
import MateStorage
/// The type of filter when searching for products.
/// Since partial SKU search is not feasible in the regular search API due to performance reason,
/// the UI separates the search for all products and by SKU.
public enum ProductSearchFilter: String, Equatable, CaseIterable {
    /// Search for all products based on the keyword.
    case all
    /// Search for products that match the SKU field.
    case sku
}


/// Implementation of `SearchUICommand` for Product search.
final class ProductSearchUICommand: SearchUICommand {
    typealias Model = MateEvent
    typealias CellViewModel = MateEvent
    typealias ResultsControllerModel = StorageEvent

    let searchBarPlaceholder = NSLocalizedString("Search products", comment: "Products Search Placeholder")

    let returnKeyType = UIReturnKeyType.done

    let searchBarAccessibilityIdentifier = "product-search-screen-search-field"

    let cancelButtonAccessibilityIdentifier = "product-search-screen-cancel-button"

    var resynchronizeModels: (() -> Void) = {}

    private var lastSearchQueryByFilter: [ProductSearchFilter: String] = [:]
    private var filter: ProductSearchFilter = .all

    private let stores: StoresManager
    private let analytics: MateAnalytics
    private let isSearchProductsBySKUEnabled: Bool
    private let onProductSelection: (MateEvent) -> Void
    private let onCancel: () -> Void

    init(
         stores: StoresManager = ServiceLocator.stores,
         analytics: MateAnalytics = ServiceLocator.analytics,
         isSearchProductsBySKUEnabled: Bool = true,
         onProductSelection: @escaping (MateEvent) -> Void,
         onCancel: @escaping () -> Void) {
        self.stores = stores
        self.analytics = analytics
        self.isSearchProductsBySKUEnabled = isSearchProductsBySKUEnabled
        self.onProductSelection = onProductSelection
        self.onCancel = onCancel
    }

    func createResultsController() -> ResultsController<ResultsControllerModel> {
        let storageManager = ServiceLocator.storageManager
        let predicate = NSPredicate(format: "id == %lld", 1)
        let descriptor = NSSortDescriptor(key: "name", ascending: true)

        return ResultsController<StorageEvent>(storageManager: storageManager, matching: predicate, sortedBy: [descriptor])
    }

    func createStarterViewController() -> UIViewController? {
        nil
    }

    func createHeaderView() -> UIView? {
        guard isSearchProductsBySKUEnabled else {
            return nil
        }
        let segmentedControl: UISegmentedControl = {
            let segmentedControl = UISegmentedControl()

            let filters: [ProductSearchFilter] = [.all, .sku]
            for (index, filter) in filters.enumerated() {
                segmentedControl.insertSegment(withTitle: filter.title, at: index, animated: false)
                if filter == self.filter {
                    segmentedControl.selectedSegmentIndex = index
                }
            }
            segmentedControl.on(.valueChanged) { [weak self] sender in
                let index = sender.selectedSegmentIndex
                guard let filter = filters[safe: index] else {
                    return
                }
                self?.showResults(filter: filter)
            }
            return segmentedControl
        }()

        let containerView = UIView(frame: .zero)
        containerView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        containerView.pinSubviewToAllEdges(segmentedControl, insets: .init(top: 8, left: 16, bottom: 16, right: 16))
        return containerView
    }

    func configureEmptyStateViewControllerBeforeDisplay(viewController: EmptyStateViewController,
                                                        searchKeyword: String) {
        let boldSearchKeyword = NSAttributedString(string: searchKeyword,
                                                   attributes: [.font: EmptyStateViewController.Config.messageFont.bold])

        let format = NSLocalizedString("We're sorry, we couldn't find results for “%@”",
                                       comment: "Message for empty Products search results. The %@ is a placeholder for the text entered by the user.")
        let message = NSMutableAttributedString(string: format)
        message.replaceFirstOccurrence(of: "%@", with: boldSearchKeyword)

        viewController.configure(.simple(message: message, image: .emptySearchResultsImage))
    }

    func createCellViewModel(model: MateEvent) -> MateEvent {
        MateEvent(id: 0,
                  name: nil,
                  startTime: nil,
                  categoryID: nil,
                  createdAt: nil,
                  updatedAt: nil,
                  userID: nil,
                  address: nil,
                  latitude: nil,
                  longitude: nil,
                  maxAttendees: nil,
                  joinedAttendees: nil,
                  category: nil,
                  user: nil,
                  status: nil)
    }

    /// Synchronizes the Products matching a given Keyword
    ///
    func synchronizeModels(siteID: Int64, keyword: String, pageNumber: Int, pageSize: Int, onCompletion: ((Bool) -> Void)?) {
        if isSearchProductsBySKUEnabled {
            // Returns early if the search query is the same for the given filter and for the first page to avoid duplicate API requests when
            // switching filter tabs.
            if let lastFilterSearchQuery = lastSearchQueryByFilter[filter],
               lastFilterSearchQuery == keyword,
               pageNumber == SyncingCoordinator.Defaults.pageFirstIndex {
                onCompletion?(true)
                return
            }
            // Skips the product search API request if the keyword is empty.
            guard keyword.isNotEmpty else {
                onCompletion?(true)
                return
            }
            lastSearchQueryByFilter[filter] = keyword
        }
//
//        let action = ProductAction.searchProducts(siteID: siteID,
//                                                  keyword: keyword,
//                                                  filter: filter,
//                                                  pageNumber: pageNumber,
//                                                  pageSize: pageSize) { result in
//            if case let .failure(error) = result {
//                DDLogError("☠️ Product Search Failure! \(error)")
//            }
//
//            onCompletion?(result.isSuccess)
//        }
//
//        stores.dispatch(action)

//        analytics.track(.productListSearched, withProperties: isSearchProductsBySKUEnabled ? ["filter": filter.analyticsValue]: nil)
    }

    func didSelectSearchResult(model: MateEvent, from viewController: UIViewController, reloadData: () -> Void, updateActionButton: () -> Void) {
        onProductSelection(model)
    }

    func shouldDeselectSearchResultOnSelection() -> Bool {
        return false
    }

    func searchResultsPredicate(keyword: String) -> NSPredicate? {
        guard isSearchProductsBySKUEnabled else {
            return NSPredicate(format: "ANY searchResults.keyword = %@", keyword)
        }
        guard keyword.isNotEmpty else {
            return nil
        }
        return NSPredicate(format: "SUBQUERY(searchResults, $result, $result.keyword = %@ AND $result.filterKey = %@).@count > 0",
                           keyword, filter.rawValue)
    }

    func cancel(from viewController: UIViewController) {
        onCancel()
    }
}

private extension ProductSearchUICommand {
    func showResults(filter: ProductSearchFilter) {
        guard filter != self.filter else {
            return
        }
        self.filter = filter
        resynchronizeModels()
    }
}

extension ProductSearchFilter {
    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("All Products", comment: "Title of the product search filter to search for all products.")
        case .sku:
            return NSLocalizedString("SKU", comment: "Title of the product search filter to search for products that match the SKU.")
        }
    }

    /// The value that is set in the analytics event property.
    var analyticsValue: String {
        switch self {
        case .all:
            return "all"
        case .sku:
            return "sku"
        }
    }
}

/// NSMutableAttributedString: Helper Methods
///
extension NSMutableAttributedString {



    /// Replaces the first found occurrence of `target` with the `replacement`.
    ///
    /// Example usage:
    ///
    /// ```
    /// let attributedString = NSMutableAttributedString(string: "Hello, #{person}")
    /// let replacement = NSAttributedString(string: "Slim Shady",
    ///                                      attributes: [.font: UIFont.boldSystemFont(ofSize: 32)])
    /// attributedString.replaceFirstOccurrence(of: "#{person}", with: replacement)
    /// ```
    ///
    func replaceFirstOccurrence(of target: String, with replacement: NSAttributedString) {
        guard let range = string.range(of: target) else {
            return
        }
        let nsRange = NSRange(range, in: string)

        replaceCharacters(in: nsRange, with: replacement)
    }

    /// Sets a link to a substring in an attributed string.
    ///
    @discardableResult
    func setAsLink(textToFind: String, linkURL: String) -> Bool {
        let foundRange = mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }

    /// Underlines the given substring (case insensitive). It does nothing if the given substring cannot be found in the original string.
    ///
    func underlineSubstring(underlinedText: String) {
        let range = (string as NSString).range(of: underlinedText, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(.underlineStyle,
                               value: NSUnderlineStyle.single.rawValue,
                               range: range)
        }

    }
}
