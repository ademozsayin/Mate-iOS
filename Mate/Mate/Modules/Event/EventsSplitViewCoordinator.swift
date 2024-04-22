//
//  EventsSplitViewCoordinator.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Combine
import UIKit
import FiableRedux
import MateNetworking

/// Coordinates the state of multiple columns (product list and secondary view) based on the secondary view.
final class EventsSplitViewCoordinator: NSObject {
    /// Content type that is shown in the secondary view.
    enum SecondaryViewContentType: Equatable {
        case empty
        case eventForm(event: MateEvent?)
    }

    /// The source of truth of the content shown in the secondary view.
    @Published private var contentTypes: [SecondaryViewContentType] = []
    private var selectedEvent: AnyPublisher<MateEvent?, Never> {
        $contentTypes.map { contentTypes -> MateEvent? in
            guard let contentType = contentTypes.last, case let .eventForm(mateEvent) = contentType else {
                return nil
            }
            return mateEvent
        }.eraseToAnyPublisher()
    }
    private var subscriptions: Set<AnyCancellable> = []

    private let splitViewController: UISplitViewController
    private let primaryNavigationController: UINavigationController
    private let secondaryNavigationController: UINavigationController
    private lazy var productsViewController = EventsViewController(selectedEvent: selectedEvent,
                                                                     navigateToContent: showFromProductList
    )

    private var addProductCoordinator: AddEventCoordinator?

    init(splitViewController: UISplitViewController) {
        self.splitViewController = splitViewController
        self.primaryNavigationController = OnsaTabNavigationController()
        self.secondaryNavigationController = OnsaNavigationController()
    }

    /// Called when the split view is ready to be shown, like after the split view is added to the view hierarchy.
    func start() {
        configureSplitView()
//        autoSelectProductOnInitialDataLoad()
    }

    /// Called when the split view is collapsing from the expanded state to determine which column to show in the collapsed mode.
    /// - Returns: The column to show when the split view is collapsed.
    func columnToShowWhenSplitViewIsCollapsing() -> UISplitViewController.Column {
        guard let lastContentType = contentTypes.last else {
            return .primary
        }
        return lastContentType == .empty ? .primary : .secondary
    }

    /// Called when the split view transitions from collapsed to expanded mode.
    func didExpand() {
        // Auto-selects the first product if there is no content to be shown.
        if contentTypes.isEmpty {
            showEmptyViewOrFirstProduct()
        }
    }

    func startProductCreation() {
        productsViewController.startProductCreation()
    }
}

private extension EventsSplitViewCoordinator {
    func showFromProductList(content: EventsViewController.NavigationContentType) {
        switch content {
            case let .productForm(product):
                showProductFormIfNoUnsavedChanges(product: product)
            case let .addProduct(sourceView, isFirstProduct):
                startProductCreationIfNoUnsavedChanges(sourceView: sourceView, isFirstProduct: isFirstProduct)
            case .search:
            print("search")
//                let searchCommand = ProductSearchUICommand(siteID: siteID, onProductSelection: { [weak self] product in
//                    self?.showProductFormIfNoUnsavedChanges(product: product)
//                }, onCancel: { [weak self] in
//                    guard let self else { return }
//                    primaryNavigationController.viewControllers = [productsViewController]
//                    primaryNavigationController.setNavigationBarHidden(false, animated: true)
//                })
//                let searchViewController = SearchViewController(storeID: siteID,
//                                                                command: searchCommand,
//                                                                cellType: ProductsTabProductTableViewCell.self,
//                                                                cellSeparator: .none,
//                                                                selectedObject: selectedProduct,
//                                                                isSelectedObject: {
//                    $0.productID == $1?.productID
//                })
//                primaryNavigationController.viewControllers = [searchViewController]
        }
    }
}

private extension EventsSplitViewCoordinator {
    func showEmptyView() {
        let config = EmptyStateViewController.Config.simple(
            message: .init(string: Localization.emptyViewMessage),
            image: .emptyProductsTabImage
        )
        let emptyStateViewController = EmptyStateViewController(style: .basic, configuration: config)
        showSecondaryView(contentType: .empty, viewController: emptyStateViewController, replacesNavigationStack: true)
    }

    func showProductFormIfNoUnsavedChanges(product: MateEvent) {
//        whenSecondaryViewProductHasNoUnsavedChanges { [weak self] in
            self.showProductForm(product: product)
//        }
    }

    func showProductForm(product: MateEvent) {
//        ProductDetailsFactory.productDetails(product: product,
//                                             presentationStyle: .navigationStack,
//                                             forceReadOnly: false,
//                                             onDeleteCompletion: { [weak self] in
//            self?.onSecondaryProductFormDeletion()
//        }) { [weak self] viewController in
//            self?.showSecondaryView(contentType: .productForm(product: product), viewController: viewController, replacesNavigationStack: true)
//        }
    }

    func startProductCreationIfNoUnsavedChanges(sourceView: AddEventCoordinator.SourceView, isFirstProduct: Bool) {
//        whenSecondaryViewProductHasNoUnsavedChanges { [weak self] in
            self.startProductCreation(sourceView: sourceView, isFirstProduct: isFirstProduct)
//        }
    }

    func startProductCreation(sourceView: AddEventCoordinator.SourceView, isFirstProduct: Bool) {
        let addProductCoordinator = AddEventCoordinator(
                                                          source: .productsTab,
                                                          sourceView: sourceView,
                                                          sourceNavigationController: primaryNavigationController,
                                                          isFirstProduct: isFirstProduct,
                                                          navigateToProductForm: { [weak self] viewController in
//            self?.showSecondaryView(contentType: .productForm(product: nil), viewController: viewController, replacesNavigationStack: true)
        }, onDeleteCompletion: { [weak self] in
            self?.onSecondaryProductFormDeletion()
        })
//        addProductCoordinator.onProductCreated = { [weak self] product in
//            guard let self, let lastContentType = contentTypes.last, lastContentType == .productForm(product: nil) else { return }
//            contentTypes[contentTypes.count - 1] = .productForm(product: product)
//        }
        addProductCoordinator.start()
        self.addProductCoordinator = addProductCoordinator
    }

    func whenSecondaryViewProductHasNoUnsavedChanges(then closure: @escaping () -> Void) {
        // Closes the product form in the secondary view only if there are no unsaved changes or if the user chooses to discard the changes.
        // This works based on the assumption that there is only one product form in the secondary navigation stack.
  
    }

    func showSecondaryView(contentType: SecondaryViewContentType, viewController: UIViewController, replacesNavigationStack: Bool) {
        if replacesNavigationStack {
            secondaryNavigationController.setViewControllers([viewController], animated: false)
            contentTypes = [contentType]
        } else {
            secondaryNavigationController.pushViewController(viewController, animated: false)
            contentTypes.append(contentType)
        }

        splitViewController.show(.secondary)
    }

    func onSecondaryProductFormDeletion() {
        splitViewController.show(.primary)
        if !splitViewController.isCollapsed {
            showEmptyViewOrFirstProduct()
        }
    }

    func showEmptyViewOrFirstProduct() {
        showEmptyView()
        switch primaryNavigationController.topViewController {
            case let productsViewController as EventsViewController:
                productsViewController.selectFirstProductIfAvailable()
//            case let productSearchViewController as SearchViewController<ProductsTabProductTableViewCell, ProductSearchUICommand>:
//                productSearchViewController.selectFirstObjectIfAvailable()
            case let .some(viewController):
                assertionFailure("Unexpected type for the products tab primary view controller: \(viewController)")
            case .none:
                break
        }
    }
}

private extension EventsSplitViewCoordinator {
    func configureSplitView() {
        primaryNavigationController.viewControllers = [productsViewController]
        splitViewController.setViewController(primaryNavigationController, for: .primary)

        splitViewController.setViewController(secondaryNavigationController, for: .secondary)
        showEmptyView()

        primaryNavigationController.delegate = self
        secondaryNavigationController.delegate = self
    }

    func EventsSplitViewCoordinator() {
        Publishers.CombineLatest(selectedEvent, productsViewController.onDataReloaded)
            .filter { [weak self] selectedEvent, onDataReloaded in
                guard let self else {
                    return false
                }
                return selectedEvent == nil && !splitViewController.isCollapsed
            }
            .first()
            .sink { [weak self] selectedEvent, onDataReloaded in
                self?.productsViewController.selectFirstProductIfAvailable()
            }
            .store(in: &subscriptions)
    }
}

extension EventsSplitViewCoordinator: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if willNavigateFromTheLastSecondaryViewControllerToProductListInCollapsedMode(navigationController, willShow: viewController) {
            contentTypes = []
            secondaryNavigationController.viewControllers = []
            return
        }

        if let tabNavigationController = navigationController as? OnsaTabNavigationController {
            tabNavigationController.navigationController(navigationController, willShow: viewController, animated: animated)
        }

        // The goal here is to detect when the user pops a view controller in the secondary navigation stack like from tapping the back button,
        // so that the secondary content types state can be updated accordingly.
        // There is no proper way that I can find to detect this, as a workaround it checks whether the secondary navigation stack has fewer
        // view controllers than the latest content types state when a different view controller is about to show.
        guard navigationController == secondaryNavigationController else {
            return
        }
        if navigationController.viewControllers.count < contentTypes.count {
            contentTypes.removeLast()
        }
    }
}

private extension EventsSplitViewCoordinator {
    /// In the collapsed mode, the secondary navigation controller is added to the primary navigation stack and the primary navigation stack is shown.
    /// When the user taps the back button to leave the last secondary view controller (e.g. product form), we want to reset `contentTypes`
    /// while there is no proper callback that I can find other than observing the primary navigation controller's `willShow`.
    /// As a workaround, it checks the following to empty out the secondary view content types:
    /// - Split view is collapsed
    /// - The navigation controller that will show a view controller is the primary one
    /// - The current content types state is still non-empty, i.e. some secondary content is currently shown
    /// - The view controller to show in the primary navigation stack is the product list
    func willNavigateFromTheLastSecondaryViewControllerToProductListInCollapsedMode(_ navigationController: UINavigationController,
                                                                                    willShow viewController: UIViewController) -> Bool {
//        let isNavigatingToProductList = viewController == productsViewController ||
//        viewController is SearchViewController<ProductsTabProductTableViewCell, ProductSearchUICommand>
//        return splitViewController.isCollapsed && navigationController == primaryNavigationController
//            && contentTypes.isNotEmpty && isNavigatingToProductList
//        
        return true
    }
}

private extension EventsSplitViewCoordinator {
    private enum Localization {
        static let emptyViewMessage = NSLocalizedString(
            "productsTab.emptySecondaryView.message",
            value: "No product selected",
            comment: "Message on the secondary view of the products tab split view before any product is selected."
        )
    }
}
