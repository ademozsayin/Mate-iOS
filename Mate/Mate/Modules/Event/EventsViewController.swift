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

/// Shows a list of products with pull to refresh and infinite scroll
/// TODO: it will be good to have unit tests for this, introducing a `ViewModel`
///
final class EventsViewController: UIViewController, GhostableViewController {
    
    
    enum NavigationContentType {
        case productForm(product: MateEvent)
        case addProduct(sourceView: AddEventCoordinator.SourceView, isFirstProduct: Bool)
        case search
    }

    @State var viewModel: EventListViewModel

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
        refreshControl.addTarget(
            self,
            action: #selector(pullToRefresh(sender:)),
            for: .valueChanged
        )
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
        button.accessibilityLabel = NSLocalizedString("Add an event", comment: "The action to add an event")
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

    /// Container of the top banner that shows that the Products feature is still work in progress.
    ///
    private lazy var topBannerContainerView: SwappableSubviewContainerView = SwappableSubviewContainerView()

    /// Top banner that shows that the Products feature is still work in progress.
    ///
    private var topBannerView: TopBannerView?


//    private var selectedEventListener: EntityListener<MateEvent>?


    /// Keep track of the (Autosizing Cell's) Height. This helps us prevent UI flickers, due to sizing recalculations.
    ///
    private var estimatedRowHeights = [IndexPath: CGFloat]()

    /// Indicates if there are no results onscreen.
    ///
    private var isEmpty: Bool = true {
        didSet {
            print("isEmpty: \(isEmpty)")
        }
    }

    /// Supports infinite scroll.
    private let scrollWatcher = ScrollWatcher()
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


    /// Set to `true` when a category is applied to the product filters and the value has changed after a remote sync.
    private var categoryHasChangedRemotely: Bool = false

    /// Set when an empty state view controller is displayed.
    ///
    private var emptyStateViewController: UIViewController?

    /// Set when sync fails, and used to display an error loading data banner
    ///
    private var dataLoadingError: Error?

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
//        self.paginationTracker = PaginationTracker()
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
        registerTableViewCells()
        showTopBannerViewIfNeeded()
        stateCoordinator.transitionToLoadingState()
        
        viewModel.getUserEvents(page: 1)
        
        viewModel.onDataLoadingError = { [weak self] error in
            self?.dataLoadingError = error
            // Show error banner view if needed
            self?.showTopBannerViewIfNeeded()
            self?.stateCoordinator.transitionToResultsUpdatedState(hasData: false)
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

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

    func updatedSelectedItems() {
        updateNavigationBarTitleForEditing()
    }

    @objc func selectAllProducts() {
//        ServiceLocator.analytics.track(event: .ProductsList.bulkUpdateSelectAllTapped())

//        viewModel.selectProducts(resultsController.fetchedObjects)
        updatedSelectedItems()
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }

    @objc func dismissModal() {
        dismiss(animated: true)
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
            "Events",
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
            button.accessibilityLabel = NSLocalizedString("Search events", comment: "Search events")
            button.accessibilityHint = NSLocalizedString(
                "Retrieves a list of events that contain a given keyword.",
                comment: "VoiceOver accessibility hint, informing the user the button can be used to search products."
            )
            button.accessibilityIdentifier = "product-search-button"

            return button
        }()
        rightBarButtonItems.append(searchItem)



        navigationItem.rightBarButtonItems = rightBarButtonItems
    }

    func configureNavigationBarForEditing() {
        updateNavigationBarTitleForEditing()
    }

    func updateNavigationBarTitleForEditing() {
        let selectedProducts = viewModel.selectedProductsCount
//        if selectedProducts == 0 {
//            navigationItem.title = Localization.bulkEditingTitle
//        } else {
//            navigationItem.title = String.localizedStringWithFormat(Localization.bulkEditingItemsTitle, String(selectedProducts))
//        }
    }

    /// Apply Woo styles.
    ///
    func configureMainView() {
        view.backgroundColor = .listBackground
    }

    func configureTabBarItem() {
        tabBarItem.title = NSLocalizedString("Events", comment: "Title of the Events tab — plural form of Events")
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
    
    
        toolbarBottomSeparator.backgroundColor = .systemColor(.separator)
        toolbarBottomSeparatorHeightConstraint.constant = 1.0 / UIScreen.main.scale
    }

    func configureScrollWatcher() {
        scrollWatcher.startObservingScrollPosition(tableView: tableView)
    }

    /// Register table cells.
    ///
    func registerTableViewCells() {
        tableView.register(ProductsTabProductTableViewCell.self)
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

//        toolbar.isHidden = filters.numberOfActiveFilters == 0 ? isEmpty : false
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
//        ServiceLocator.analytics.track(.productListPulledToRefresh)

        sender.endRefreshing()
        
//        refreshControl.resetAnimation(in: tableView) { [unowned self] in
//            // ghost animation is also removed after switching tabs
//            // show make sure it's displayed again
//            self.refreshControl.endRefreshing()
//            self.removeGhostContent()
//            self.displayGhostContent(over: tableView)
//        }

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
        return createNoProductsConfig()
    }

    /// Creates EmptyStateViewController.Config for no products empty view
    ///
    func createNoProductsConfig() ->  EmptyStateViewController.Config {
        let message = NSLocalizedString("No events yet",
                                        comment: "The text on the placeholder overlay when there are no products on the Products tab")
        let details = NSLocalizedString("Start creating event today join your first event.",
                                        comment: "The details on the placeholder overlay when there are no products on the Products tab")
        let buttonTitle = NSLocalizedString("Add Event",
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

// MARK: - Finite State Machine Management
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
        case .loading:
            displayGhostContent(over: tableView)
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
        case .loading:
            ensureFooterSpinnerIsStopped()
            removeGhostContent()
            showTopBannerViewIfNeeded()
            showOrHideToolbar()
        case .results:
            showTopBannerViewIfNeeded()
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
        
        static let cancel = NSLocalizedString("Cancel", comment: "Title of an option to dismiss the bulk edit action sheet")


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



