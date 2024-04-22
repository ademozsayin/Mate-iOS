//
//  EventsViewController.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import UIKit
import SwiftUI
import FiableUI
import FiableRedux
import Combine
import FiableFoundation
import MateNetworking

import class AutomatticTracks.CrashLogging

/// Shows a list of products with pull to refresh and infinite scroll
/// TODO: it will be good to have unit tests for this, introducing a `ViewModel`
///
final class EventsViewController: UIViewController, GhostableViewController {
    
    enum NavigationContentType {
        case productForm(product: MateEvent)
        case addProduct(sourceView: AddEventCoordinator.SourceView, isFirstProduct: Bool)
        case search
    }

    let viewModel: EventListViewModel

    /// Main TableView
    ///
    @IBOutlet weak var tableView: UITableView!

    
    lazy var ghostTableViewController = GhostTableViewController(
        options: GhostTableViewOptions(sectionHeaderVerticalSpace: .medium,
                                       cellClass: ProductCategoryTableViewCell.self,
                                       rowsPerSection: Constants.placeholderRowsPerSection,
                                       estimatedRowHeight: Constants.estimatedRowHeight,
                                       separatorStyle: .none,
                                    isScrollEnabled: false))


    /// Pull To Refresh Support.
    ///
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh(sender:)), for: .valueChanged)
        return refreshControl
    }()

    /// Footer "Loading More" Spinner.
    ///
    private lazy var footerSpinnerView = FooterSpinnerView()

    /// Empty Footer Placeholder. Replaces spinner view and allows footer to collapse and be completely hidden.
    ///
    private lazy var footerEmptyView = UIView(frame: .zero)

    /// Top stack view that is shown above the table view as the table header view.
    ///
    private lazy var topStackView: UIStackView = {
        let subviews = [topBannerContainerView]
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        stackView.spacing = Constants.headerViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    /// The button in the navigation bar to add a product
    ///
    private lazy var addProductButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: .plusBarButtonItemImage,
                                     style: .plain,
                                     target: self,
                                     action: #selector(addProduct(_:)))
        button.accessibilityTraits = .button
        button.accessibilityLabel = NSLocalizedString("Add a product", comment: "The action to add a product")
        button.accessibilityIdentifier = "product-add-button"
        return button
    }()

    /// Top toolbar that shows the sort and filter CTAs.
    ///
    @IBOutlet private weak var toolbar: ToolbarView!
    @IBOutlet private weak var toolbarBottomSeparator: UIView!
    @IBOutlet private weak var toolbarBottomSeparatorHeightConstraint: NSLayoutConstraint!

    // Used to trick the navigation bar for large title (ref: issue 3 in p91TBi-45c-p2).
    private let hiddenScrollView = UIScrollView()

    /// The filter CTA in the top toolbar.
    private lazy var filterButton: UIButton = UIButton(frame: .zero)

    /// The bulk edit CTA in the navbar.
    private lazy var bulkEditButton: UIBarButtonItem = {
        let button = UIBarButtonItem(title: Localization.bulkEditingToolbarButtonTitle,
                                     style: .plain,
                                     target: self,
                                     action: #selector(openBulkEditingOptions(sender:)))
        button.isEnabled = false
        return button
    }()

    /// Container of the top banner that shows that the Products feature is still work in progress.
    ///
    private lazy var topBannerContainerView: SwappableSubviewContainerView = SwappableSubviewContainerView()

    /// Top banner that shows that the Products feature is still work in progress.
    ///
    private var topBannerView: TopBannerView?

    /// ResultsController: Surrounds us. Binds the galaxy together. And also, keeps the UITableView <> (Stored) Products in sync.
    ///
//    private lazy var resultsController: ResultsController<StorageEvent> = {
//        let resultsController = createResultsController(siteID: siteID)
//        configureResultsController(resultsController, onReload: { [weak self] in
//            guard let self else { return }
//            self.reloadTableAndView()
//        })
//        return resultsController
//    }()

//    private var selectedEventListener: EntityListener<MateEvent>?

    private var sortOrder: EventsSortOrder = .default {
        didSet {
            if sortOrder != oldValue {
//                updateLocalProductSettings(sort: sortOrder,
//                                           filters: filters)
//                resultsController.updateSortOrder(sortOrder)
//
//                /// Reload data because `updateSortOrder` generates a new `predicate` which calls `performFetch`
//                tableView.reloadData()
//
//                paginationTracker.resync()
            }
        }
    }

    /// Keep track of the (Autosizing Cell's) Height. This helps us prevent UI flickers, due to sizing recalculations.
    ///
    private var estimatedRowHeights = [IndexPath: CGFloat]()

    /// Indicates if there are no results onscreen.
    ///
    private var isEmpty: Bool {
        return true//resultsController.isEmpty
    }

    /// Supports infinite scroll.
    private let scrollWatcher = ScrollWatcher()
    private let paginationTracker: PaginationTracker
    private var scrollWatcherSubscription: AnyCancellable?

    private lazy var stateCoordinator: PaginatedListViewControllerStateCoordinator = {
        let stateCoordinator = PaginatedListViewControllerStateCoordinator(onLeavingState: { [weak self] state in
            self?.didLeave(state: state)
            }, onEnteringState: { [weak self] state in
                self?.didEnter(state: state)
        })
        return stateCoordinator
    }()

//    private let imageService: ImageService = ServiceLocator.imageService

    private var filters: FilterProductListViewModel.Filters = FilterProductListViewModel.Filters() {
        didSet {
            if filters != oldValue ||
                categoryHasChangedRemotely {
//                updateLocalProductSettings(sort: sortOrder,
//                                           filters: filters)
                updateFilterButtonTitle(filters: filters)

//                resultsController.updatePredicate(siteID: siteID,
//                                                  stockStatus: filters.stockStatus,
//                                                  productStatus: filters.productStatus,
//                                                  productType: filters.promotableProductType?.productType)

                /// Reload because `updatePredicate` calls `performFetch` when creating a new predicate
                tableView.reloadData()

                paginationTracker.resync()
            }
        }
    }

    /// Set to `true` when a category is applied to the product filters and the value has changed after a remote sync.
    private var categoryHasChangedRemotely: Bool = false

    /// Set when an empty state view controller is displayed.
    ///
    private var emptyStateViewController: UIViewController?

    /// Set when sync fails, and used to display an error loading data banner
    ///
    @Published private var dataLoadingError: Error?

    /// Store plan banner presentation handler.
    ///
    private var subscriptions: Set<AnyCancellable> = []

    private var addProductCoordinator: AddEventCoordinator?

    /// Tracks if the swipe actions have been glanced to the user.
    ///
    private var swipeActionsGlanced = false

    private let isSplitViewEnabled: Bool
    private let navigateToContent: (NavigationContentType) -> Void
    private let selectedEvent: AnyPublisher<MateEvent?, Never>
    private let onTableViewEditingEnd: PassthroughSubject<Void, Never> = .init()
    let onDataReloaded: PassthroughSubject<Void, Never> = .init()

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - View Lifecycle

    init(
        selectedEvent: AnyPublisher<MateEvent?, Never>,
        featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService,
        navigateToContent: @escaping (NavigationContentType) -> Void
    ) {
        self.viewModel = .init( stores: ServiceLocator.stores)
        self.selectedEvent = selectedEvent
        self.isSplitViewEnabled = featureFlagService.isFeatureFlagEnabled(.splitViewInProductsTab)
        self.navigateToContent = navigateToContent
        self.paginationTracker = PaginationTracker()
        super.init(nibName: type(of: self).nibName, bundle: nil)

        configureTabBarItem()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        registerUserActivity()

        configureNavigationBar()
        configureMainView()
        configureTableView()
        configureHiddenScrollView()
        configureToolbar()
        configureScrollWatcher()
        configurePaginationTracker()
//        configureStorePlanBannerPresenter()
        registerTableViewCells()

        showTopBannerViewIfNeeded()
        syncProductsSettings()
        observeSelectedProductAndDataLoadedStateToUpdateSelectedRow()
        observeSelectedProductToAutoScrollWhenProductChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if AppRatingManager.shared.shouldPromptForAppReview() {
//            displayRatingPrompt()
        }

        // Fix any incomplete animation of the refresh control
        // when switching tabs mid-animation
        refreshControl.resetAnimation(in: tableView) { [unowned self] in
            // ghost animation is also removed after switching tabs
            // show make sure it's displayed again
            self.removeGhostContent()
            self.displayGhostContent(over: tableView)
        }

//        navigationController?.navigationBar.removeShadow()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        finishBulkEditing()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTableHeaderViewHeight()
    }

    override var shouldShowOfflineBanner: Bool {
        return true
    }

    /// Selects the first product if one is available. Invoked when no product is selected when data is loaded in split view expanded mode.
    func selectFirstProductIfAvailable() {
//        guard let firstProduct = resultsController.fetchedObjects.first else {
//            return
//        }
//        didSelectProduct(product: firstProduct)
    }

    func startProductCreation() {
        addProduct(sourceBarButtonItem: addProductButton, isFirstProduct: false)
    }
}

// MARK: - Navigation Bar Actions
//
private extension EventsViewController {
    @IBAction func displaySearchProducts() {
        ServiceLocator.analytics.track(.productListMenuSearchTapped)
        navigateToContent(.search)
    }

    @objc func addProduct(_ sender: UIBarButtonItem) {
        addProduct(sourceBarButtonItem: sender, isFirstProduct: false)
    }

    func addProduct(sourceBarButtonItem: UIBarButtonItem? = nil,
                    sourceView: UIView? = nil,
                    isFirstProduct: Bool) {
        let sourceView: AddEventCoordinator.SourceView? = {
            if let sourceBarButtonItem = sourceBarButtonItem {
                return .barButtonItem(sourceBarButtonItem)
            } else if let sourceView = sourceView {
                return .view(sourceView)
            } else {
                assertionFailure("No source view for adding a product")
                return nil
            }
        }()
        guard let sourceView else {
            return
        }
        guard isSplitViewEnabled else {
            guard let navigationController else {
                return
            }

            let source: AddEventCoordinator.Source = .productsTab
            let coordinatingController = AddEventCoordinator(
                source: source,
                sourceView: sourceView,
                sourceNavigationController: navigationController,
                isFirstProduct: isFirstProduct
            )

            coordinatingController.start()
            self.addProductCoordinator = coordinatingController
            return
        }

        navigateToContent(.addProduct(sourceView: sourceView, isFirstProduct: isFirstProduct))
    }
}

// MARK: - Bulk Editing flows
//
private extension EventsViewController {
    @objc func startBulkEditing() {
        tableView.setEditing(true, animated: true)

        // Disable pull-to-refresh while editing
        refreshControl.removeFromSuperview()

        configureNavigationBarForEditing()
        showOrHideToolbar()
    }

    @objc func finishBulkEditing() {
        guard let tableView, tableView.isEditing else {
            return
        }

        viewModel.deselectAll()
        tableView.setEditing(false, animated: true)
        onTableViewEditingEnd.send(())

        bulkEditButton.isEnabled = false

        // Enable pull-to-refresh
        tableView.addSubview(refreshControl)

        configureNavigationBar()
        showOrHideToolbar()
    }

    func updatedSelectedItems() {
        updateNavigationBarTitleForEditing()
        bulkEditButton.isEnabled = viewModel.bulkEditActionIsEnabled
    }

    @objc func selectAllProducts() {
//        ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateSelectAllTapped())

//        viewModel.selectProducts(resultsController.fetchedObjects)
        updatedSelectedItems()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }

    @objc func openBulkEditingOptions(sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let updateStatus = UIAlertAction(title: Localization.bulkEditingStatusOption, style: .default) { [weak self] _ in
            self?.showStatusBulkEditingModal()
        }
        let updatePrice = UIAlertAction(title: Localization.bulkEditingPriceOption, style: .default) { [weak self] _ in
            self?.showPriceBulkEditingModal()
        }
        let cancelAction = UIAlertAction(title: Localization.cancel, style: .cancel)

        actionSheet.addAction(updateStatus)
//        if !viewModel.onlyPriceIncompatibleProductsSelected {
//            actionSheet.addAction(updatePrice)
//        }
        actionSheet.addAction(cancelAction)

        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.barButtonItem = sender
        }

        present(actionSheet, animated: true)
    }

    func showStatusBulkEditingModal() {
//        ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateRequested(field: .status, selectedProductsCount: viewModel.selectedProductsCount))

//        let initialStatus = viewModel.commonStatusForSelectedProducts
//        let command = ProductStatusSettingListSelectorCommand(selected: initialStatus)
//        let listSelectorViewController = ListSelectorViewController(command: command) { _ in
//            // view dismiss callback - no-op
//        }
//        listSelectorViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
//                                                                                      target: self,
//                                                                                      action: #selector(dismissModal))
//
//        let applyButton = UIBarButtonItem(title: Localization.bulkEditingApply)
//        applyButton.on(call: { [weak self] _ in
//            self?.applyBulkEditingStatus(newStatus: command.selected, modalVC: listSelectorViewController)
//        })
//        command.$selected.sink { newStatus in
//            if let newStatus, newStatus != initialStatus {
//                applyButton.isEnabled = true
//            } else {
//                applyButton.isEnabled = false
//            }
//        }.store(in: &subscriptions)
//        listSelectorViewController.navigationItem.rightBarButtonItem = applyButton
//
//        present(OnsaNavigationController(rootViewController: listSelectorViewController), animated: true)
    }

    @objc func dismissModal() {
        dismiss(animated: true)
    }

//    func applyBulkEditingStatus(newStatus: ProductStatus?, modalVC: UIViewController) {
//        guard let newStatus else { return }
//
//        ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateConfirmed(field: .status, selectedProductsCount: viewModel.selectedProductsCount))
//
//        displayProductsSavingInProgressView(on: modalVC)
//        viewModel.updateSelectedProducts(with: newStatus) { [weak self] result in
//            guard let self else { return }
//
//            self.dismiss(animated: true, completion: nil)
//            switch result {
//            case .success:
//                self.finishBulkEditing()
//                self.presentNotice(title: Localization.statusUpdatedNotice)
//                ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateSuccess(field: .status))
//            case .failure:
//                self.presentNotice(title: Localization.updateErrorNotice)
//                ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateFailure(field: .status))
//            }
//        }
//    }

    func showPriceBulkEditingModal() {
//        ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateRequested(field: .price, selectedProductsCount: viewModel.selectedProductsCount))
//
//        let priceInputViewModel = PriceInputViewModel(productListViewModel: viewModel)
//        let priceInputViewController = PriceInputViewController(viewModel: priceInputViewModel)
//        priceInputViewModel.cancelClosure = { [weak self] in
//            self?.dismissModal()
//        }
//        priceInputViewModel.applyClosure = { [weak self] newPrice in
//            self?.applyBulkEditingPrice(newPrice: newPrice, modalVC: priceInputViewController)
//        }
//        present(WooNavigationController(rootViewController: priceInputViewController), animated: true)
    }

    func applyBulkEditingPrice(newPrice: String?, modalVC: UIViewController) {
//        guard let newPrice else { return }
//
//        ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateConfirmed(field: .price, selectedProductsCount: viewModel.selectedProductsCount))
//
//        displayProductsSavingInProgressView(on: modalVC)
//        viewModel.updateSelectedProducts(with: newPrice) { [weak self] result in
//            guard let self else { return }
//
//            self.dismiss(animated: true, completion: nil)
//            switch result {
//            case .success:
//                self.finishBulkEditing()
//                self.presentNotice(title: Localization.priceUpdatedNotice)
//                ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateSuccess(field: .price))
//            case .failure:
//                self.presentNotice(title: Localization.updateErrorNotice)
//                ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateFailure(field: .price))
//            }
//        }
    }

    func displayProductsSavingInProgressView(on vc: UIViewController) {
        let viewProperties = InProgressViewProperties(title: Localization.productsSavingTitle, message: Localization.productsSavingMessage)
        let inProgressViewController = InProgressViewController(viewProperties: viewProperties)
        inProgressViewController.modalPresentationStyle = .fullScreen

        vc.present(inProgressViewController, animated: true, completion: nil)
    }

    func presentNotice(title: String) {
        let contextNoticePresenter: NoticePresenter = {
            let noticePresenter = DefaultNoticePresenter()
            noticePresenter.presentingViewController = tabBarController
            return noticePresenter
        }()
        contextNoticePresenter.enqueue(notice: .init(title: title))
    }

    func presentNotice(notice: Notice) {
        let contextNoticePresenter: NoticePresenter = {
            let noticePresenter = DefaultNoticePresenter()
            noticePresenter.presentingViewController = tabBarController
            return noticePresenter
        }()
        contextNoticePresenter.enqueue(notice: notice)
    }
}

// MARK: - View Configuration
//
private extension EventsViewController {

    /// Set the title.
    ///
    func configureNavigationBar() {
        navigationItem.title = NSLocalizedString(
            "Products",
            comment: "Title that appears on top of the Product List screen (plural form of the word Product)."
        )
        configureNavigationBarRightButtonItems()
    }


    func configureNavigationBarRightButtonItems() {
        var rightBarButtonItems = [UIBarButtonItem]()
        rightBarButtonItems.append(addProductButton)

        let searchItem: UIBarButtonItem = {
            let button = UIBarButtonItem(image: .searchBarButtonItemImage,
                                         style: .plain,
                                         target: self,
                                         action: #selector(displaySearchProducts))
            button.accessibilityTraits = .button
            button.accessibilityLabel = NSLocalizedString("Search products", comment: "Search Products")
            button.accessibilityHint = NSLocalizedString(
                "Retrieves a list of products that contain a given keyword.",
                comment: "VoiceOver accessibility hint, informing the user the button can be used to search products."
            )
            button.accessibilityIdentifier = "product-search-button"

            return button
        }()
        rightBarButtonItems.append(searchItem)

        let bulkEditItem: UIBarButtonItem = {
            let button = UIBarButtonItem(image: .multiSelectIcon,
                                         style: .plain,
                                         target: self,
                                         action: #selector(startBulkEditing))
            button.accessibilityTraits = .button
            button.accessibilityLabel = Localization.bulkEditingNavBarButtonTitle
            button.accessibilityHint = Localization.bulkEditingNavBarButtonHint

            return button
        }()
        rightBarButtonItems.append(bulkEditItem)


        navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    func configureNavigationBarForEditing() {
        updateNavigationBarTitleForEditing()
        configureNavigationBarItemsForEditing()
    }

    func updateNavigationBarTitleForEditing() {
        let selectedProducts = viewModel.selectedProductsCount
        if selectedProducts == 0 {
            navigationItem.title = Localization.bulkEditingTitle
        } else {
            navigationItem.title = String.localizedStringWithFormat(Localization.bulkEditingItemsTitle, String(selectedProducts))
        }
    }

    func configureNavigationBarItemsForEditing() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel,
                                                           target: self,
                                                           action: #selector(finishBulkEditing))
        navigationItem.rightBarButtonItems = [bulkEditButton]
    }

    /// Apply Woo styles.
    ///
    func configureMainView() {
        view.backgroundColor = .listBackground
    }

    func configureTabBarItem() {
        tabBarItem.title = NSLocalizedString("Products", comment: "Title of the Products tab — plural form of Product")
        tabBarItem.image = .productImage
        tabBarItem.accessibilityIdentifier = "tab-bar-products-item"
    }

    /// Configure common table properties.
    ///
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.estimatedRowHeight = Constants.estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension

        tableView.backgroundColor = .listBackground
        tableView.tableFooterView = footerSpinnerView
        tableView.separatorStyle = .none

        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.accessibilityIdentifier = "products-table-view"

        // Adds the refresh control to table view manually so that the refresh control always appears below the navigation bar title in
        // large or normal size to be consistent with Dashboard and Orders tab with large titles workaround.
        // If we do `tableView.refreshControl = refreshControl`, the refresh control appears in the navigation bar when large title is shown.
        tableView.addSubview(refreshControl)

        let headerContainer = UIView(frame: CGRect(x: 0, y: 0, width: Int(tableView.frame.width), height: Int(Constants.headerDefaultHeight)))
        headerContainer.backgroundColor = .systemColor(.secondarySystemGroupedBackground)
        headerContainer.addSubview(topStackView)
        headerContainer.pinSubviewToSafeArea(topStackView, insets: Constants.headerContainerInsets)
        let bottomBorderView = UIView.createBorderView()
        headerContainer.addSubview(bottomBorderView)
        NSLayoutConstraint.activate([
            bottomBorderView.constrainToSuperview(attribute: .leading),
            bottomBorderView.constrainToSuperview(attribute: .trailing),
            bottomBorderView.constrainToSuperview(attribute: .bottom)
        ])
        tableView.tableHeaderView = headerContainer

        // Updates products tab state after table view is configured, otherwise the initial state is always showing results.
        stateCoordinator.transitionToResultsUpdatedState(hasData: !isEmpty)
    }

    private func configureHiddenScrollView() {
        // Configure large title using the `hiddenScrollView` trick.
        hiddenScrollView.configureForLargeTitleWorkaround()
        // Adds the "hidden" scroll view to the root of the UIViewController for large title workaround.
        view.addSubview(hiddenScrollView)
        view.sendSubviewToBack(hiddenScrollView)
        hiddenScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.pinSubviewToAllEdges(hiddenScrollView, insets: .zero)
    }

    /// Configure toolbar view by number of products
    ///
    private func configureToolbar() {
        setupToolbar()
        showOrHideToolbar()
    }

    private func setupToolbar() {
        let sortTitle = NSLocalizedString("Sort by", comment: "Title of the toolbar button to sort products in different ways.")
        let sortButton = UIButton(frame: .zero)
        sortButton.setTitle(sortTitle, for: .normal)
        sortButton.addTarget(self, action: #selector(sortButtonTapped(sender:)), for: .touchUpInside)

        let filterTitle = NSLocalizedString("Filter", comment: "Title of the toolbar button to filter products by different attributes.")
        filterButton.setTitle(filterTitle, for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        filterButton.accessibilityIdentifier = "product-filter-button"

        [sortButton, filterButton].forEach {
            $0.applyLinkButtonStyle()
            var configuration = UIButton.Configuration.plain()
            configuration.contentInsets = Constants.toolbarButtonInsets
            $0.configuration = configuration
        }

        toolbar.backgroundColor = .systemColor(.secondarySystemGroupedBackground)
        toolbar.setSubviews(leftViews: [sortButton], rightViews: [filterButton])

        toolbarBottomSeparator.backgroundColor = .systemColor(.separator)
        toolbarBottomSeparatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }

    func configureScrollWatcher() {
        scrollWatcher.startObservingScrollPosition(tableView: tableView)
    }

    func configurePaginationTracker() {
        paginationTracker.delegate = self
//        scrollWatcherSubscription = scrollWatcher.trigger.sink { [weak self] _ in
//            self?.paginationTracker.ensureNextPageIsSynced()
//        }
    }

    /// Register table cells.
    ///
    func registerTableViewCells() {
//        tableView.register(ProductsTabProductTableViewCell.self)
    }

    /// Show or hide the toolbar based on number of products
    /// if there is any filter applied, toolbar must be always visible
    /// If there is 0 products, toolbar will be hidden
    /// if there is 1 or more products, toolbar will be visible
    ///
    func showOrHideToolbar() {
        guard !tableView.isEditing else {
            toolbar.isHidden = true
            return
        }

        toolbar.isHidden = filters.numberOfActiveFilters == 0 ? isEmpty : false
    }

}

// MARK: - Updates
//
private extension EventsViewController {

    /// Slightly reveal swipe actions of the first visible cell that contains at least one swipe action.
    /// This action is performed only once, using `swipeActionsGlanced` as a control variable.
    ///
    func glanceTrailingActionsIfNeeded() {
        if !swipeActionsGlanced {
            swipeActionsGlanced = true
            tableView.glanceTrailingSwipeActions()
        }
    }

    /// Displays an error banner if there is an error loading products data.
    ///
    func showTopBannerViewIfNeeded() {
        if let error = dataLoadingError {
            requestAndShowErrorTopBannerView(for: error)
        }
    }

    /// Request a new product banner from `ProductsTopBannerFactory` and wire actionButtons actions
    /// To show a top banner, we can dispatch a loadFeedbackVisibility action from AppSettingsStore and update the top banner accordingly
    /// Ref: https://github.com/woocommerce/woocommerce-ios/issues/6682
    ///
//    func requestAndShowNewTopBannerView(for bannerType: ProductsTopBannerFactory.BannerType) {
//        let isExpanded = topBannerView?.isExpanded ?? false
//
//    }

    /// Request a new error loading data banner from `ErrorTopBannerFactory` and display it in the table header
    ///
    func requestAndShowErrorTopBannerView(for error: Error) {
        let errorBanner = ErrorTopBannerFactory.createTopBanner(for: error,
            expandedStateChangeHandler: { [weak self] in
                self?.tableView.updateHeaderHeight()
            },
            onTroubleshootButtonPressed: { [weak self] in
                guard let self else { return }

                WebviewHelper.launch(ErrorTopBannerFactory.troubleshootUrl(for: error), with: self)
            },
            onContactSupportButtonPressed: { [weak self] in
                guard let self = self else { return }
                let supportForm = SupportFormHostingController(viewModel: .init())
                supportForm.show(from: self)
            })
        topBannerContainerView.updateSubview(errorBanner)
        topBannerView = errorBanner
        updateTableHeaderViewHeight()
    }

    func hideTopBannerView() {
        topBannerView?.removeFromSuperview()
        topBannerView = nil
        updateTableHeaderViewHeight()
    }

    /// Updates table header view with the correct spacing / edges depending if `topBannerContainerView` is empty or not.
    ///
    func updateTableHeaderViewHeight() {
        topStackView.spacing = topBannerContainerView.subviews.isNotEmpty ? Constants.headerViewSpacing : 0
        tableView.updateHeaderHeight()
    }

    

    /// Configure resultController.
    /// Assign closures and start performBatch
    ///
    

    /// Set closure  to methods `onDidChangeContent` and `onDidResetContent


    /// Manages view components and reload tableview
    ///
    func reloadTableAndView() {
        showOrHideToolbar()
        addOrRemoveOverlay()
        tableView.reloadData()
        onDataReloaded.send(())
    }

    /// Add or remove the overlay based on number of products
    /// If there is 0 products, overlay will be added
    /// if there is 1 or more products, toolbar will be removed
    ///
    func addOrRemoveOverlay() {
        guard isEmpty else {
            removeAllOverlays()
            return
        }
        displayNoResultsOverlay()
    }

    /// We sync the local product settings for configuring local sorting and filtering.
    /// If there are some info stored when this screen is loaded, the data will be updated using the stored sort/filters.
    /// If any of the filters has to be synchronize remotely, it is done so after the filters are loaded, and the data updated if necessary.
    /// If no info are stored (so there is a failure), we resynchronize the syncingCoordinator for updating the screen using the default sort/filters.
    ///
    func syncProductsSettings() {

    }

    func observeSelectedProductAndDataLoadedStateToUpdateSelectedRow() {
//        Publishers.CombineLatest3(selectedEvent,
//                                  // Giving it an initial value to enable the combined publisher from the beginning.
//                                  onDataReloaded.merge(with: Just<Void>(())),
//                                  // Giving it an initial value to enable the combined publisher from the beginning.
//                                  onTableViewEditingEnd.merge(with: Just<Void>(())))
//            .map { $0.0 }
//            .withPrevious()
//            .sink { [weak self] previousSelectedProduct, selectedEvent in
//                guard let self else { return }
//
//                let currentSelectedIndexPath = tableView.indexPathForSelectedRow
//                let selectedIndexPath = selectedProduct != nil ? resultsController.indexPath(forObjectMatching: {
//                    $0.productID == selectedProduct?.productID
//                }): nil
//                if let selectedIndexPath {
//                    guard currentSelectedIndexPath != selectedIndexPath else {
//                        return
//                    }
//                    if let currentSelectedIndexPath {
//                        tableView.deselectRow(at: currentSelectedIndexPath, animated: false)
//                    }
//
//                    let scrollPosition: UITableView.ScrollPosition = {
//                        let hasSelectedProductChanged = (selectedProduct != previousSelectedProduct)
//                        guard hasSelectedProductChanged else { return .none }
//                        let isSelectedIndexPathVisible = self.isIndexPathVisible(selectedIndexPath)
//                        return isSelectedIndexPathVisible ? .none : .middle
//                    }()
//
//                    tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: scrollPosition)
//                } else if let currentSelectedIndexPath {
//                    tableView.deselectRow(at: currentSelectedIndexPath, animated: false)
//                }
//            }
//            .store(in: &subscriptions)
    }

    func observeSelectedProductToAutoScrollWhenProductChanges() {
        selectedEvent.compactMap { $0 }
            .sink { [weak self] selectedEvent in
                self?.listenToSelectedProductToAutoScrollWhenProductChanges(product: selectedEvent)
            }
            .store(in: &subscriptions)
    }

    func listenToSelectedProductToAutoScrollWhenProductChanges(product: MateEvent) {
//        selectedProductListener = .init(storageManager: ServiceLocator.storageManager, readOnlyEntity: product)
//        selectedProductListener?.onUpsert = { [weak self] product in
//            guard let self,
//                  let selectedIndexPath = tableView.indexPathForSelectedRow,
//                  !isIndexPathVisible(selectedIndexPath) else {
//                return
//            }
//            tableView.scrollToRow(at: selectedIndexPath, at: .middle, animated: false)
//        }
    }

    func isIndexPathVisible(_ indexPath: IndexPath) -> Bool {
        guard let indexPathsForVisibleRows = tableView.indexPathsForVisibleRows else {
            return false
        }
        return indexPathsForVisibleRows.contains(indexPath)
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension EventsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
       return 1// resultsController.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return 1 //resultsController.sections[section].numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(ProductsTabProductTableViewCell.self, for: indexPath)
//        let product = resultsController.object(at: indexPath)
//        let viewModel = ProductsTabProductViewModel(product: product)
//        cell.update(viewModel: viewModel, imageService: imageService)

//        return cell
        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension EventsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return estimatedRowHeights[indexPath] ?? Constants.estimatedRowHeight
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (splitViewController?.isCollapsed == true || !isSplitViewEnabled) &&
            !tableView.isEditing {
            tableView.deselectRow(at: indexPath, animated: true)
        }

//        let product = resultsController.object(at: indexPath)

        if tableView.isEditing {
//            viewModel.selectProduct(product)
            updatedSelectedItems()
        } else {
//            ServiceLocator.analytics.track(event:
//                    .Products.productListProductTapped(horizontalSizeClass: UITraitCollection.current.horizontalSizeClass))

//            didSelectProduct(product: product)
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard tableView.isEditing else {
            return
        }

//        let product = resultsController.object(at: indexPath)
//        viewModel.deselectProduct(product)
//        updatedSelectedItems()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        let productIndex = resultsController.objectIndex(from: indexPath)

        // Preserve the Cell Height
        // Why: Because Autosizing Cells, upon reload, will need to be laid yout yet again. This might cause
        // UI glitches / unwanted animations. By preserving it, *then* the estimated will be extremely close to
        // the actual value. AKA no flicker!
        //
        estimatedRowHeights[indexPath] = cell.frame.height

        // Restore cell selection state
//        if tableView.isEditing {
//            let product = resultsController.object(at: indexPath)
//            if self.viewModel.productIsSelected(product) {
//                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//            } else {
//                tableView.deselectRow(at: indexPath, animated: false)
//            }
//        }
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        onTableViewEditingEnd.send(())
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hiddenScrollView.updateFromScrollViewDidScrollEventForLargeTitleWorkaround(scrollView)
    }

    /// Provide an implementation to show cell swipe actions. Return `nil` to provide no action.
    ///
//    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let product = resultsController.object(at: indexPath)
//        guard ServiceLocator.stores.sessionManager.defaultSite?.isPublic == true,
//              product.productStatus == .published,
//              let url = URL(string: product.permalink),
//            let cell = tableView.cellForRow(at: indexPath) else {
//            return nil
//        }
//        let shareAction = UIContextualAction(style: .normal, title: nil, handler: { [weak self] _, _, completionHandler in
//            guard let self,
//                  let navigationController = self.navigationController else {
//                return
//            }
//            let shareProductCoordinator = ShareProductCoordinator(siteID: self.siteID,
//                                                                  productURL: url,
//                                                                  productName: product.name,
//                                                                  productDescription: product.fullDescription ?? product.shortDescription ?? "",
//                                                                  shareSheetAnchorView: cell,
//                                                                  navigationController: navigationController)
//            shareProductCoordinator.start()
//            self.shareProductCoordinator = shareProductCoordinator
//            ServiceLocator.analytics.track(.productListShareButtonTapped)
//            completionHandler(true) // Tells the table that the action was performed and forces it to go back to its original state (un-swiped)
//        })
//        shareAction.backgroundColor = .brand
//        shareAction.image = .init(systemName: "square.and.arrow.up")
//
//        return UISwipeActionsConfiguration(actions: [shareAction])
//    }
}

private extension EventsViewController {
    func didSelectProduct(product: MateEvent) {
//        guard isSplitViewEnabled else {
//            ProductDetailsFactory.productDetails(product: product,
//                                                 presentationStyle: .navigationStack,
//                                                 forceReadOnly: false) { [weak self] viewController in
//                self?.navigationController?.pushViewController(viewController, animated: true)
//            }
//            return
//        }
//        navigateToContent(.productForm(product: product))
    }
}

// MARK: - Actions
//
private extension EventsViewController {
    @objc private func pullToRefresh(sender: UIRefreshControl) {
        ServiceLocator.analytics.track(.productListPulledToRefresh)

        paginationTracker.resync {
            sender.endRefreshing()
        }
    }

    @objc func sortButtonTapped(sender: UIButton) {
//        ServiceLocator.analytics.track(.productListViewSortingOptionsTapped)
//        let title = NSLocalizedString("Sort by",
//                                      comment: "Message title for sort products action bottom sheet")
//        let viewProperties = BottomSheetListSelectorViewProperties(subtitle: title)
//        let command = ProductsSortOrderBottomSheetListSelectorCommand(selected: sortOrder) { [weak self] selectedSortOrder in
//            self?.dismiss(animated: true, completion: nil)
//            guard let selectedSortOrder = selectedSortOrder as ProductsSortOrder? else {
//                    return
//                }
//            self?.sortOrder = selectedSortOrder
//        }
//        let sortOrderListPresenter = BottomSheetListSelectorPresenter(viewProperties: viewProperties,
//                                                                      command: command)
//
//        sortOrderListPresenter.show(from: self, sourceView: sender, arrowDirections: .up)
    }

    @objc func filterButtonTapped() {
//        ServiceLocator.analytics.track(event: .ProductListFilter.productListViewFilterOptionsTapped(source: .productsTab))
//        let viewModel = FilterProductListViewModel(filters: filters, siteID: siteID)
//        let filterProductListViewController = FilterListViewController(viewModel: viewModel, onFilterAction: { [weak self] filters in
//            ServiceLocator.analytics.track(event: .ProductListFilter.productFilterListShowProductsButtonTapped(source: .productsTab, filters: filters))
//            self?.filters = filters
//        }, onClearAction: {
//            ServiceLocator.analytics.track(.productFilterListClearMenuButtonTapped)
//        }, onDismissAction: {
//            ServiceLocator.analytics.track(.productFilterListDismissButtonTapped)
//        })
//        present(filterProductListViewController, animated: true, completion: nil)
    }

    func clearFilter(sourceBarButtonItem: UIBarButtonItem? = nil, sourceView: UIView? = nil) {
        ServiceLocator.analytics.track(.productListClearFiltersTapped)
        filters = FilterProductListViewModel.Filters()
    }

    /// Presents productsFeedback survey.
    ///
    func presentProductsFeedback() {
//        let navigationController = SurveyCoordinatingController(survey: .productsFeedback)
//        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - Placeholders
//
private extension EventsViewController {

    /// Displays the overlay when there are no results.
    ///
    func displayNoResultsOverlay() {
        // Abort if we are already displaying this childController
        guard emptyStateViewController?.parent == nil else {
            return
        }
        let emptyStateViewController = EmptyStateViewController(style: .list)
        let config = createFilterConfig()
        displayEmptyStateViewController(emptyStateViewController)
        emptyStateViewController.configure(config)

        // Make sure the banner is on top of the empty state view
//        storePlanBannerPresenter?.bringBannerToFront()
    }

    func createFilterConfig() ->  EmptyStateViewController.Config {
        if filters.numberOfActiveFilters == 0 {
            return createNoProductsConfig()
        } else {
            return createNoProductsMatchFilterConfig()
        }
    }

    /// Creates EmptyStateViewController.Config for no products empty view
    ///
    func createNoProductsConfig() ->  EmptyStateViewController.Config {
        let message = NSLocalizedString("No products yet",
                                        comment: "The text on the placeholder overlay when there are no products on the Products tab")
        let details = NSLocalizedString("Start selling today by adding your first product to the store.",
                                        comment: "The details on the placeholder overlay when there are no products on the Products tab")
        let buttonTitle = NSLocalizedString("Add Product",
                                            comment: "Action to add product on the placeholder overlay when there are no products on the Products tab")
        return EmptyStateViewController.Config.withButton(
            message: .init(string: message),
            image: .emptyProductsTabImage,
            details: details,
            buttonTitle: buttonTitle,
            onTap: { [weak self] button in
                self?.addProduct(sourceView: button, isFirstProduct: true)
            },
            onPullToRefresh: { [weak self] refreshControl in
                self?.pullToRefresh(sender: refreshControl)
            })
    }

    /// Creates EmptyStateViewController.Config for no products match the filter empty view
    ///
    func createNoProductsMatchFilterConfig() ->  EmptyStateViewController.Config {
        let message = NSLocalizedString("No matching products found",
                                        comment: "The text on the placeholder overlay when no products match the filter on the Products tab")
        let buttonTitle = NSLocalizedString("Clear Filters",
                                            comment: "Action to add product on the placeholder overlay when no products match the filter on the Products tab")
        return EmptyStateViewController.Config.withButton(
            message: .init(string: message),
            image: .emptyProductsTabImage,
            details: "",
            buttonTitle: buttonTitle,
            onTap: { [weak self] button in
                self?.clearFilter(sourceView: button)
            },
            onPullToRefresh: { [weak self] refreshControl in
                self?.pullToRefresh(sender: refreshControl)
            })
    }

    /// Shows the EmptyStateViewController as a child view controller.
    ///
    func displayEmptyStateViewController(_ emptyStateViewController: UIViewController) {
        self.emptyStateViewController = emptyStateViewController
        addChild(emptyStateViewController)

        emptyStateViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStateViewController.view)

        NSLayoutConstraint.activate([
            emptyStateViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateViewController.view.topAnchor.constraint(equalTo: topStackView.bottomAnchor),
            emptyStateViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        emptyStateViewController.didMove(toParent: self)
    }

    /// Removes EmptyStateViewController child view controller if applicable.
    ///
    func removeAllOverlays() {
        guard let emptyStateViewController = emptyStateViewController, emptyStateViewController.parent == self else {
            return
        }

        emptyStateViewController.willMove(toParent: nil)
        emptyStateViewController.view.removeFromSuperview()
        emptyStateViewController.removeFromParent()
        self.emptyStateViewController = nil
    }

}

// MARK: - Sync'ing Helpers
//
extension EventsViewController: PaginationTrackerDelegate {
    func sync(pageNumber: Int, pageSize: Int, reason: String?, onCompletion: SyncCompletion?) {
        
    }
    
}

// MARK: - Finite State Machine Management
//
private extension EventsViewController {

    func didEnter(state: PaginatedListViewControllerState) {
        switch state {
        case .noResultsPlaceholder:
            displayNoResultsOverlay()
        case .syncing(let pageNumber):
            let isFirstPage = pageNumber == SyncingCoordinator.Defaults.pageFirstIndex
//            if isFirstPage && resultsController.isEmpty {
            if isFirstPage  {
                displayGhostContent(over: tableView)
            } else if !isFirstPage {
                ensureFooterSpinnerIsStarted()
            }
            // Remove error banner when sync starts
            if dataLoadingError != nil {
                hideTopBannerView()
            }
        case .results:
            glanceTrailingActionsIfNeeded()
        }
    }

    func didLeave(state: PaginatedListViewControllerState) {
        switch state {
        case .noResultsPlaceholder:
            removeAllOverlays()
        case .syncing:
            ensureFooterSpinnerIsStopped()
            removeGhostContent()
            showTopBannerViewIfNeeded()
            showOrHideToolbar()
        case .results:
            break
        }
    }

    func transitionToSyncingState(pageNumber: Int) {
        stateCoordinator.transitionToSyncingState(pageNumber: pageNumber)
    }

    func transitionToResultsUpdatedState() {
        stateCoordinator.transitionToResultsUpdatedState(hasData: !isEmpty)
    }
}

// MARK: - Filter UI Helpers
//
private extension EventsViewController {
    func updateFilterButtonTitle(filters: FilterProductListViewModel.Filters) {
        let activeFilterCount = filters.numberOfActiveFilters

        let titleWithoutActiveFilters =
            NSLocalizedString("Filter", comment: "Title of the toolbar button to filter products without any filters applied.")
        let titleFormatWithActiveFilters =
            NSLocalizedString("Filter (%ld)", comment: "Title of the toolbar button to filter products with filters applied.")

        let title = activeFilterCount > 0 ?
            String.localizedStringWithFormat(titleFormatWithActiveFilters, activeFilterCount): titleWithoutActiveFilters

        filterButton.setTitle(title, for: .normal)
    }
}

// MARK: - Spinner Helpers
//
private extension EventsViewController {

    /// Starts the Footer Spinner animation, whenever `mustStartFooterSpinner` returns *true*.
    ///
    func ensureFooterSpinnerIsStarted() {
        tableView.tableFooterView = footerSpinnerView
        footerSpinnerView.startAnimating()
    }

    /// Stops animating the Footer Spinner.
    ///
    private func ensureFooterSpinnerIsStopped() {
        footerSpinnerView.stopAnimating()
        tableView.tableFooterView = footerEmptyView
    }
}

// MARK: - Nested Types
//
private extension EventsViewController {

    enum Constants {
        static let headerViewSpacing = CGFloat(8)
        static let estimatedRowHeight = CGFloat(86)
        static let placeholderRowsPerSection = [3]
        static let headerDefaultHeight = CGFloat(130)
        static let headerContainerInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        static let toolbarButtonInsets = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)
    }

    enum Localization {
        static let bulkEditingNavBarButtonTitle = NSLocalizedString("Edit products", comment: "Action to start bulk editing of products")
        static let bulkEditingNavBarButtonHint = NSLocalizedString(
            "Edit status or price for multiple products at once",
            comment: "VoiceOver accessibility hint, informing the user the button can be used to bulk edit products"
        )

        static let selectAllToolbarButtonTitle = NSLocalizedString(
            "Select all",
            comment: "Title of a button that selects all products for bulk update"
        )
        static let bulkEditingToolbarButtonTitle = NSLocalizedString(
            "Bulk update",
            comment: "Title of a button that presents a menu with possible products bulk update options"
        )
        static let bulkEditingStatusOption = NSLocalizedString("Update status", comment: "Title of an option that opens bulk products status update flow")
        static let bulkEditingPriceOption = NSLocalizedString("Update price", comment: "Title of an option that opens bulk products price update flow")
        static let cancel = NSLocalizedString("Cancel", comment: "Title of an option to dismiss the bulk edit action sheet")

        static let bulkEditingTitle = NSLocalizedString(
            "Select items",
            comment: "Title that appears on top of the Product List screen when bulk editing starts."
        )
        static let bulkEditingItemsTitle = NSLocalizedString(
            "%1$@ selected",
            comment: "Title that appears on top of the Product List screen during bulk editing. Reads like: 2 selected"
        )

        static let bulkEditingApply = NSLocalizedString("Apply", comment: "Title for the button to apply bulk editing changes to selected products.")

        static let productsSavingTitle = NSLocalizedString("Updating your products...",
                                                          comment: "Title of the in-progress UI while bulk updating selected products remotely")
        static let productsSavingMessage = NSLocalizedString("Please wait while we update these products on your store",
                                                            comment: "Message of the in-progress UI while bulk updating selected products remotely")

        static let statusUpdatedNotice = NSLocalizedString("Status updated",
                                                           comment: "Title of the notice when a user updated status for selected products")
        static let priceUpdatedNotice = NSLocalizedString("Price updated",
                                                           comment: "Title of the notice when a user updated price for selected products")
        static let updateErrorNotice = NSLocalizedString("Cannot update products",
                                                         comment: "Title of the notice when there is an error updating selected products")
       
    }
}


extension UIRefreshControl {
    /// Reset animation of refresh control by forcing refreshing animation again
    func resetAnimation(in scrollView: UIScrollView, completion: (() -> Void)? = nil) {
        if isRefreshing {
            endRefreshing()
            scrollView.setContentOffset(CGPoint(x: 0, y: scrollView.contentOffset.y - frame.size.height), animated: true)
            beginRefreshing()
            completion?()
        }
    }
}


extension UIScrollView {
    /// Configures a scroll view to be hidden and used to relay scroll action from any of the multiple scroll views in the view hierarchy below.
    func configureForLargeTitleWorkaround() {
        contentInsetAdjustmentBehavior = .never
        isHidden = true
        bounces = false
    }

    /// Updates the hidden scroll view from `scrollViewDidScroll` events from another `UIScrollView`.
    /// - Parameter scrollView: the scroll view where `scrollViewDidScroll` events are triggered.
    func updateFromScrollViewDidScrollEventForLargeTitleWorkaround(_ scrollView: UIScrollView) {
        contentSize = scrollView.contentSize
        contentOffset = scrollView.contentOffset
        panGestureRecognizer.state = scrollView.panGestureRecognizer.state
    }
}

extension UIView {
    @discardableResult
    public func constrainToSuperview(attribute: NSLayoutConstraint.Attribute,
                                     relatedBy relation: UIKit.NSLayoutConstraint.Relation = .equal,
                                     constant: CoreGraphics.CGFloat = 0) -> UIKit.NSLayoutConstraint {
        NSLayoutConstraint(item: self,
                           attribute: attribute,
                           relatedBy: relation,
                           toItem: superview,
                           attribute: attribute,
                           multiplier: 1,
                           constant: constant)
    }
}

///
extension GhostStyle {
    static var wooDefaultGhostStyle: Self {
        return GhostStyle(beatDuration: Defaults.beatDuration,
                          beatStartColor: .listForeground(modal: false),
                          beatEndColor: .ghostCellAnimationEndColor)
    }
}
