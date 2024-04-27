import Combine
import Photos
import UIKit
import FiableUI
import FiableRedux
import MateNetworking
/// The entry UI for adding/editing a Product.
final class ProductFormViewController<ViewModel: EventFormViewModelProtocol>: UIViewController, UITableViewDelegate {
    typealias ProductModel = ViewModel.EventModel

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var moreDetailsContainerView: UIView!

    private lazy var keyboardFrameObserver: KeyboardFrameObserver = {
        let keyboardFrameObserver = KeyboardFrameObserver { [weak self] keyboardFrame in
            self?.handleKeyboardFrameUpdate(keyboardFrame: keyboardFrame)
        }
        return keyboardFrameObserver
    }()

    private let viewModel: ViewModel

    private var product: ProductModel {
        viewModel.productModel
    }

    private var tableViewModel: EventFormTableViewModel
    private var tableViewDataSource: EventFormTableViewDataSource {
        didSet {
            registerTableViewCells()
        }
    }

    private var tooltipPresenter: TooltipPresenter?

    private lazy var exitForm: () -> Void = {
        presentationStyle.createExitForm(viewController: self)
    }()

    private lazy var shareBarButtonItem = UIBarButtonItem(title: Localization.share,
                                                          style: .plain,
                                                          target: self,
                                                          action: #selector(shareProduct))

    private let presentationStyle: EventFormPresentationStyle
    private let navigationRightBarButtonItemsSubject = PassthroughSubject<[UIBarButtonItem], Never>()
    private var navigationRightBarButtonItems: AnyPublisher<[UIBarButtonItem], Never> {
        navigationRightBarButtonItemsSubject.eraseToAnyPublisher()
    }
    private var productSubscription: AnyCancellable?
    private var productNameSubscription: AnyCancellable?
    private var updateEnabledSubscription: AnyCancellable?
    private var newVariationsPriceSubscription: AnyCancellable?
    private var productImageStatusesSubscription: AnyCancellable?
    private var blazeEligibilitySubscription: AnyCancellable?


    private lazy var tooltipUseCase = ProductDescriptionAITooltipUseCase(
        isDescriptionAIEnabled: false
    )
    private var didShowTooltip = false {
        didSet {
            tooltipUseCase.numberOfTimesWriteWithAITooltipIsShown += 1
        }
    }
    
    /// The coordinator for sharing products
    ///
//    private var shareProductCoordinator: ShareProductCoordinator?

    private let onDeleteCompletion: () -> Void

    private let userDefaults: UserDefaults

    init(viewModel: ViewModel,
         presentationStyle: EventFormPresentationStyle,
         userDefaults: UserDefaults = .standard,
         onDeleteCompletion: @escaping () -> Void = {}) {
        self.viewModel = viewModel
        self.presentationStyle = presentationStyle
     
        self.userDefaults = userDefaults
        self.onDeleteCompletion = onDeleteCompletion
        self.tableViewModel = DefaultEventFormTableViewModel(product: viewModel.productModel,
                                                               actionsFactory: viewModel.actionsFactory)
        self.tableViewDataSource = EventFormTableViewDataSource(viewModel: tableViewModel)

        super.init(nibName: "ProductFormViewController", bundle: nil)
        updateDataSourceActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        productSubscription?.cancel()
        productNameSubscription?.cancel()
        updateEnabledSubscription?.cancel()
        newVariationsPriceSubscription?.cancel()
        blazeEligibilitySubscription?.cancel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configurePresentationStyle()
        configureNavigationBar()

        configureMainView()
        configureTableView()
        configureMoreDetailsContainerView()

        startListeningToNotifications()
        handleSwipeBackGesture()

        observeProduct()
        observeProductName()

//        viewModel.trackProductFormLoaded()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }

    override var shouldShowOfflineBanner: Bool {
        return true
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateNavigationBarTitle()
    }

    // MARK: - Navigation actions handling

    override func shouldPopOnBackButton() -> Bool {
        guard viewModel.hasUnsavedChanges() == false else {
            presentBackNavigationActionSheet()
            return false
        }
        return true
    }

    override func shouldPopOnSwipeBack() -> Bool {
        return shouldPopOnBackButton()
    }

    // MARK: Product save action handling

    func dismissOrPopViewController() {
        switch self.presentationStyle {
        case .navigationStack:
            self.navigationController?.popViewController(animated: true)
        default:
            self.dismiss(animated: true, completion: nil)
        }
    }

    @objc func saveProductAndLogEvent() {
        saveProduct()
    }

    @objc func publishProduct() {
        saveProduct(status: .published)
    }

    func saveProductAsDraft() {

        saveProduct(status: .draft)
    }

    // MARK: Product preview action handling

    @objc private func saveDraftAndDisplayProductPreview() {

        guard viewModel.canSaveAsDraft() || viewModel.hasUnsavedChanges() else {
//            displayProductPreview()
            return
        }

//        saveProduct(status: .draft) { [weak self] result in
//            if result.isSuccess {
//                self?.displayProductPreview()
//            }
//        }
    }


    // MARK: Navigation actions

    /// Closes the product form if the product has no unsaved changes or the user chooses to discard the changes.
    /// - Parameters:
    ///   - completion: Called when the product form is closed.
    ///   - onCancel: Called when the user chooses not to close the form from the confirmation alert.
    func close(completion: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
        guard viewModel.hasUnsavedChanges() == false else {
            presentBackNavigationActionSheet(onDiscard: completion, onCancel: onCancel)
            return
        }
        exitForm()
        completion()
    }

    @objc private func closeNavigationBarButtonTapped() {
        close()
    }

    // MARK: Action Sheet

    /// More Options Action Sheet
    ///
    @objc func presentMoreOptionsActionSheet(_ sender: UIBarButtonItem) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = .text

        if viewModel.canShowPublishOption() {
            actionSheet.addDefaultActionWithTitle(Localization.publishTitle) { [weak self] _ in
                self?.publishProduct()
            }
        }

        if viewModel.canSaveAsDraft() {
            actionSheet.addDefaultActionWithTitle(ActionSheetStrings.saveProductAsDraft) { [weak self] _ in
                self?.saveProductAsDraft()
            }
        }

        if viewModel.canShareProduct() {
            actionSheet.addDefaultActionWithTitle(ActionSheetStrings.share) { [weak self] _ in
                self?.displayShareProduct(from: sender)
            }
        }

       

        actionSheet.addCancelActionWithTitle(ActionSheetStrings.cancel) { _ in
        }

        let popoverController = actionSheet.popoverPresentationController
        popoverController?.barButtonItem = sender

        present(actionSheet, animated: true)
    }


    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !didShowTooltip else {
            return
        }

        if let tooltipPresenter {
            tooltipPresenter.showTooltip()
            didShowTooltip = true
        }
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let section = tableViewModel.sections[indexPath.section]
        switch section {
        case .primaryFields(let rows):
            let row = rows[indexPath.row]
            switch row {
            case .description(_, let isEditable, _):
                guard isEditable else {
                    return
                }
                editProductDescription()
 
            default:
                break
            }
        case .settings(let rows):
            let row = rows[indexPath.row]
            switch row {
            case .price(_, let isEditable):
                guard isEditable else {
                    return
                }
         
            case .reviews:
                ServiceLocator.analytics.track(.productDetailViewReviewsTapped)
               
            case .downloadableFiles(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewDownloadableFilesTapped)
              
            case .linkedProducts(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewLinkedProductsTapped)
              
            case .productType(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewProductTypeTapped)
                let cell = tableView.cellForRow(at: indexPath)
                editProductType(cell: cell)
            case .shipping(_, let isEditable):
                guard isEditable else {
                    return
                }
       
            case .inventory(_, let isEditable):
                guard isEditable else {
                    return
                }
    
            case .addOns(_, let isEditable):
                guard isEditable else {
                    return
                }
               
              
            case .categories(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewCategoriesTapped)
                editCategories()
            case .tags(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewTagsTapped)
               
            case .shortDescription(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewShortDescriptionTapped)
               
            case .externalURL(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewExternalProductLinkTapped)
              
                break
            case .sku(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewSKUTapped)
               
                break
            case .groupedProducts(_, let isEditable):
                guard isEditable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewGroupedProductsTapped)
               
                break
            case .variations(let row):
                guard row.isActionable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewVariationsTapped)
               
            case .noPriceWarning(let viewModel):
                guard viewModel.isActionable else {
                    return
                }
                ServiceLocator.analytics.track(.productDetailViewVariationsTapped)
               
            case .attributes(_, let isEditable):
                guard isEditable else {
                    return
                }
              
            case .status:
                break
            case .bundledProducts(_, let isActionable):
                guard isActionable else {
                    return
                }
               
            case .components(_, let isActionable):
                guard isActionable else {
                    return
                }
              
            case .subscriptionFreeTrial(_, let isEditable):
                guard isEditable else {
                    return
                }

               
            case .subscriptionExpiry(_, let isEditable):
                guard isEditable else {
                    return
                }

              
            case .noVariationsWarning:
                print("noVariationsWarning")
                return // This warning is not actionable.
            case .quantityRules:
                print("quantityRules")
                return
            }
        }
    }

    @objc private func shareProduct() {
        displayShareProduct(from: shareBarButtonItem)
    }
}

// MARK: - Configuration
//
private extension ProductFormViewController {

    /// Configure navigation bar with the title
    ///
    func configureNavigationBar(title: String = "") {
        updateNavigationBar()
        updateBackButtonTitle()
        updateNavigationBarTitle()
    }

    func configureMainView() {
        view.backgroundColor = .basicBackground
    }

    func configureTableView() {
        registerTableViewCells()

        tableView.dataSource = tableViewDataSource
        tableView.delegate = self
        tableView.accessibilityIdentifier = "product-form"
        tableView.cellLayoutMarginsFollowReadableWidth = true

        tableView.backgroundColor = .listForeground(modal: false)
        tableView.removeLastCellSeparator()

        // Since the table view is in a container under a stack view, the safe area adjustment should be handled in the container view.
        tableView.contentInsetAdjustmentBehavior = .never

        tableView.reloadData()
    }

    /// Registers all of the available TableViewCells
    ///
    func registerTableViewCells() {
        tableViewModel.sections.forEach { section in
            switch section {
            case .primaryFields(let rows):
                rows.forEach { row in
                    row.cellTypes.forEach { cellType in
                        tableView.registerNib(for: cellType)
                    }
                }
            case .settings(let rows):
                rows.forEach { row in
                    row.cellTypes.forEach { cellType in
                        tableView.registerNib(for: cellType)
                    }
                }
            }
        }
    }

    func configurePresentationStyle() {
        switch presentationStyle {
        case .contained(let containerViewController):
            containerViewController()?.addCloseNavigationBarButton(target: self, action: #selector(closeNavigationBarButtonTapped))
        case .navigationStack:
            break
        }
    }

    func configureMoreDetailsContainerView() {
        let title = NSLocalizedString("Add more details", comment: "Title of the button at the bottom of the product form to add more product details.")
        let viewModel = BottomButtonContainerView.ViewModel(style: .link,
                                                            title: title,
                                                            image: .plusImage) { [weak self] button in
                                                                self?.moreDetailsButtonTapped(button: button)
        }
        let buttonContainerView = BottomButtonContainerView(viewModel: viewModel)

        moreDetailsContainerView.addSubview(buttonContainerView)
        moreDetailsContainerView.pinSubviewToAllEdges(buttonContainerView)
        moreDetailsContainerView.setContentCompressionResistancePriority(.required, for: .vertical)
        moreDetailsContainerView.setContentHuggingPriority(.required, for: .vertical)

        updateMoreDetailsButtonVisibility()
    }
}

// MARK: - Tooltip
//
private extension ProductFormViewController {
    func tooltipTargetPoint() -> CGPoint {
        return .zero
//        guard let indexPath = findDescriptionAICellIndexPath() else {
//            return .zero
//        }
//
//        guard let cell = tableView.cellForRow(at: indexPath),
//              let buttonCell = cell as? ButtonTableViewCell,
//              let imageView = buttonCell.button.imageView else {
//            return .zero
//        }
//
//        let rectOfButtonInTableView = tableView.convert(buttonCell.button.frame, from: buttonCell)
//
//        return CGPoint(
//            x: rectOfButtonInTableView.minX + imageView.frame.midX,
//            y: rectOfButtonInTableView.maxY
//        )
    }

    func updateTooltipPresenter() {
        if let tooltipPresenter {
            tooltipPresenter.removeTooltip()
            self.tooltipPresenter = nil
        }

        guard tooltipUseCase.shouldShowTooltip(for: product) == true else {
            return
        }

        let tooltip = Tooltip(containerWidth: tableView.bounds.width)

        tooltip.title = "Localization.AITooltip.title"
        tooltip.message = "Localization.AITooltip.message"
        tooltip.primaryButtonTitle = "Localization.AITooltip.gotIt"
        tooltipPresenter = TooltipPresenter(
            containerView: tableView,
            tooltip: tooltip,
            target: .point(tooltipTargetPoint),
            primaryTooltipAction: { [weak self] in
                self?.tooltipUseCase.hasDismissedWriteWithAITooltip = true
            }
        )
        tooltipPresenter?.tooltipVerticalPosition = .below
    }
}

// MARK: - Observations & responding to changes
//
private extension ProductFormViewController {
    func observeProduct() {
        productSubscription = viewModel.observableProduct.sink { [weak self] product in
            self?.onProductUpdated(product: product)
        }
    }

    /// Observe product name changes and re-render the product if the change happened outside this screen.
    ///
    /// This method covers the following case:
    /// 1. User changes the product name locally
    /// 2. User creates an attribute or a variation (This updates the whole product, overriding the unsaved product name)
    /// 3. ViewModel detects that there was a pending name change and fires an event to the name observable
    /// 4. View re-renders un-saved product name and updates the save button state.
    ///
    /// The "happened outside" condition is needed to not reload the view while the user is typing a new name.
    ///
    func observeProductName() {
        productNameSubscription = viewModel.productName?.sink { [weak self] _ in
            guard let self = self else { return }
            self.updateBackButtonTitle()
            if self.view.window == nil { // If window is nil, this screen isn't the active screen.
                self.onProductUpdated(product: self.product)
            }
        }
    }

    /// Updates table viewmodel and datasource and attempts to animate cell deletion/insertion.
    ///
    func reloadLinkedPromoCellAnimated() {
        let indexPathBeforeReload = findLinkedPromoCellIndexPath()
        tableViewModel = DefaultEventFormTableViewModel(product: viewModel.productModel,
                                                          actionsFactory: viewModel.actionsFactory)
        let indexPathAfterReload = findLinkedPromoCellIndexPath()

        reconfigureDataSource(tableViewModel: tableViewModel) { [weak self] in
            guard let self = self else { return }

            switch (indexPathBeforeReload, indexPathAfterReload) {
            case (let indexPathBeforeReload?, nil):
                self.tableView.deleteRows(at: [indexPathBeforeReload], with: .left)
            case (nil, let indexPathAfterReload?):
                self.tableView.insertRows(at: [indexPathAfterReload], with: .automatic)
            default:
                self.tableView.reloadData()
            }
        }
    }

    func findLinkedPromoCellIndexPath() -> IndexPath? {
//        for (sectionIndex, section) in tableViewModel.sections.enumerated() {
//            if case .primaryFields(rows: let sectionRows) = section {
//                for (rowIndex, row) in sectionRows.enumerated() {
//                    if case .linkedProductsPromo = row {
//                        return IndexPath(row: rowIndex, section: sectionIndex)
//                    }
//                }
//            }
//        }
        return nil
    }

    func onProductUpdated(product: ProductModel) {
        updateMoreDetailsButtonVisibility()
        tableViewModel = DefaultEventFormTableViewModel(product: product,
                                                          actionsFactory: viewModel.actionsFactory
        )
        reconfigureDataSource(tableViewModel: tableViewModel)
    }



    /// Recreates the `tableViewModel` and reloads the `table` & `datasource`.
    ///
    func updateFormTableContent() {
        tableViewModel = DefaultEventFormTableViewModel(product: product,
                                                          actionsFactory: viewModel.actionsFactory)
        reconfigureDataSource(tableViewModel: tableViewModel)
    }



    /// Recreates `tableViewDataSource` and reloads the `tableView` data.
    /// - Parameters:
    ///   - reloadClosure: custom tableView reload action, by default `reloadData()` will be triggered
    ///
    func reconfigureDataSource(tableViewModel: EventFormTableViewModel, reloadClosure: (() -> Void)? = nil) {
        tableViewDataSource = EventFormTableViewDataSource(viewModel: tableViewModel)
        updateDataSourceActions()
        tableView.dataSource = tableViewDataSource

        if let reloadClosure = reloadClosure {
            reloadClosure()
        } else {
            tableView.reloadData()
        }

        updateTooltipPresenter()
    }

    func updateDataSourceActions() {
        
        tableViewDataSource.openAILegalPageAction = { [weak self] url in
            guard let self else { return }
            WebviewHelper.launch(url.absoluteString, with: self)
        }
        tableViewDataSource.configureActions(onNameChange: { [weak self] name in
            self?.onEditProductNameCompletion(newName: name ?? "")
        }, onStatusChange: { [weak self] isEnabled in
            self?.onEditStatusCompletion(isEnabled: isEnabled)
        })
    }
}

// MARK: More details actions
//
private extension ProductFormViewController {
    func moreDetailsButtonTapped(button: UIButton) {
//        let title = NSLocalizedString("Add more details",
//                                      comment: "Title of the bottom sheet from the product form to add more product details.")
//        let viewProperties = BottomSheetListSelectorViewProperties(subtitle: title)
//        let actions = viewModel.actionsFactory.bottomSheetActions()
//        let dataSource = ProductFormBottomSheetListSelectorCommand(
//            actions: actions
//        ) { [weak self] action in
//            self?.dismiss(animated: true) { [weak self] in
//                switch action {
//                case .editCategories:
//                    ServiceLocator.analytics.track(.productDetailViewCategoriesTapped)
//                    self?.editCategories()
//                }
//            }
//        }
//        let listSelectorPresenter = BottomSheetListSelectorPresenter(viewProperties: viewProperties, command: dataSource)
//        listSelectorPresenter.show(from: self, sourceView: button.titleLabel ?? button, arrowDirections: .down)
    }

    func updateMoreDetailsButtonVisibility() {
//        let moreDetailsActions = viewModel.actionsFactory.bottomSheetActions()
//        moreDetailsContainerView.isHidden = moreDetailsActions.isEmpty
    }
}

// MARK: Navigation actions
//
private extension ProductFormViewController {
    func saveProduct(status: EventStatus? = nil, onCompletion: @escaping (Result<Void, OnsaApiError>) -> Void = { _ in }) {
        
    }

    func saveProductRemotely(status: EventStatus?, onCompletion: @escaping (Result<Void, OnsaApiError>) -> Void = { _ in }) {}

    func displayError(error: OnsaApiError?, title: String = "Localization.updateProductError") {
        let message = error?.localizedDescription
        displayErrorAlert(title: title, message: message)
    }

    func displayErrorAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let cancel = UIAlertAction(title: NSLocalizedString(
            "OK",
            comment: "Dismiss button on the alert when there is an error updating the product"
        ), style: .cancel, handler: nil)
        alert.addAction(cancel)

        present(alert, animated: true, completion: nil)
    }


    func displayShareProduct(from sourceView: UIBarButtonItem) {
        
    }
}

// MARK: Navigation Bar Items
//
private extension ProductFormViewController {

    /// Even if the back button don't show any text, we still need a back button title for the menu that is presented by long pressing the back button.
    ///
    func updateBackButtonTitle() {
        navigationItem.backButtonTitle = viewModel.productModel.name.isNotEmpty ? viewModel.productModel.name : Localization.unnamedProduct
    }

    func updateNavigationBarTitle() {
        guard traitCollection.horizontalSizeClass != .compact else {
            title = nil
            return
        }
      
        title = Localization.defaultTitle
       
    }

    func updateNavigationBar() {
        // Create action buttons based on view model
        let rightBarButtonItems: [UIBarButtonItem] = viewModel.actionButtons.reversed().map { buttonType in
            switch buttonType {
            case .preview:
                return createPreviewBarButtonItem()
            case .publish:
                return createPublishBarButtonItem()
            case .save:
                return createSaveBarButtonItem()
            case .more:
                return createMoreOptionsBarButtonItem()
            case .share:
                return shareBarButtonItem
            }
        }

        navigationItem.rightBarButtonItems = rightBarButtonItems
        switch presentationStyle {
        case .contained(let containerViewController):
            containerViewController()?.navigationItem.rightBarButtonItems = rightBarButtonItems
        default:
            break
        }
    }

    func createPublishBarButtonItem() -> UIBarButtonItem {
        let publishButton = UIBarButtonItem(title: Localization.publishTitle,
                                            style: .done,
                                            target: self,
                                            action: #selector(publishProduct))
        publishButton.accessibilityIdentifier = "publish-product-button"
        return publishButton
    }

    func createSaveBarButtonItem() -> UIBarButtonItem {
        let saveButton = UIBarButtonItem(title: Localization.saveTitle,
                                         style: .done,
                                         target: self,
                                         action: #selector(saveProductAndLogEvent))
        saveButton.accessibilityIdentifier = "save-product-button"
        return saveButton
    }

    func createPreviewBarButtonItem() -> UIBarButtonItem {
        let previewButton = UIBarButtonItem(title: "Localization.previewTitle", style: .done, target: self, action: #selector(saveDraftAndDisplayProductPreview))
        previewButton.isEnabled = viewModel.shouldEnablePreviewButton()
        return previewButton
    }

    func createMoreOptionsBarButtonItem() -> UIBarButtonItem {
        let moreButton = UIBarButtonItem(image: .moreImage,
                                     style: .plain,
                                     target: self,
                                     action: #selector(presentMoreOptionsActionSheet(_:)))
        moreButton.accessibilityLabel = NSLocalizedString("More options", comment: "Accessibility label for the Edit Product More Options action sheet")
        moreButton.accessibilityIdentifier = "edit-product-more-options-button"
        return moreButton
    }
}

// MARK: - Keyboard management
//
private extension ProductFormViewController {
    /// Registers for all of the related Notifications
    ///
    func startListeningToNotifications() {
        keyboardFrameObserver.startObservingKeyboardFrame()
    }
}

extension ProductFormViewController: KeyboardScrollable {
    var scrollable: UIScrollView {
        return tableView
    }
}

// MARK: - Navigation actions handling
//
private extension ProductFormViewController {
    func presentBackNavigationActionSheet(onDiscard: @escaping () -> Void = {}, onCancel: @escaping () -> Void = {}) {
        let exitForm: () -> Void = {
            presentationStyle.createExitForm(viewController: self, completion: onDiscard)
        }()
        let viewControllerToPresentAlert = navigationController?.topViewController ?? self
        switch viewModel.formType {
        case .add:
            UIAlertController.presentDiscardNewProductActionSheet(viewController: viewControllerToPresentAlert,
                                                                  onSaveDraft: { [weak self] in
                self?.saveProductAsDraft()
            }, onDiscard: {
                exitForm()
            }, onCancel: {
                onCancel()
            })
        case .edit:
            UIAlertController.presentDiscardChangesActionSheet(viewController: viewControllerToPresentAlert,
                                                               onDiscard: {
                exitForm()
            }, onCancel: {
                onCancel()
            })
        case .readonly:
            break
        }
    }
}

// MARK: Action - Edit Product Name
//
private extension ProductFormViewController {
    func onEditProductNameCompletion(newName: String) {
//        viewModel.updateName(newName)

        /// This refresh is used to adapt the size of the cell to the text
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}

// MARK: Action - Edit Product Description
//
private extension ProductFormViewController {
    func editProductDescription() {

    }

    func onEditProductDescriptionCompletion(newDescription: String) {

    }
}

// MARK: Action - Edit Product Type Settings
//
private extension ProductFormViewController {
    func editProductType(cell: UITableViewCell?) {

    }
}

// MARK: Action - Edit Product Categories

private extension ProductFormViewController {
    func editCategories() {
        guard let product = product as? EditableEventModel else {
            return
        }
    }

    func onEditCategoriesCompletion(categories: [MateCategory]) {
        guard let product = product as? EditableEventModel else {
            return
        }
    }
}

// MARK: Action - Edit Status (Enabled/Disabled)
//
private extension ProductFormViewController {
    func onEditStatusCompletion(isEnabled: Bool) {
//        viewModel.updateStatus(isEnabled)
    }
}

// MARK: Constants
//
private enum Localization {
    static let share = NSLocalizedString("Share", comment: "Action for sharing a product from the product details screen")
    static let publishTitle = NSLocalizedString("Publish", comment: "Action for creating a new product remotely with a published status")
    static let saveTitle = NSLocalizedString("Save", comment: "Action for saving a Product remotely")

    static let unnamedProduct = NSLocalizedString("Unnamed product",
                                                  comment: "Back button title when the product doesn't have a name")

    static let updateProductError = NSLocalizedString("Cannot update product", comment: "The title of the alert when there is an error updating the product")
 
    static let defaultTitle = NSLocalizedString("productForm.defaultTitle", value: "Product", comment: "Product title")

}

private enum ActionSheetStrings {
    static let saveProductAsDraft = NSLocalizedString("Save as draft",
                                                      comment: "Button title to save a product as draft in Product More Options Action Sheet")
    static let viewProduct = NSLocalizedString("View Product in Store",
                                               comment: "Button title View product in store in Edit Product More Options Action Sheet")
    static let share = NSLocalizedString("Share", comment: "Button title Share in Edit Product More Options Action Sheet")
    static let promoteWithBlaze = NSLocalizedString("Promote with Blaze", comment: "Button title Promote with Blaze in Edit Product More Options Action Sheet")
    static let trashProduct = NSLocalizedString("productForm.bottomSheet.trashAction",
                                                value: "Trash product",
                                                comment: "Button title Trash product in Edit Product More Options Action Sheet")
    static let productSettings = NSLocalizedString("Product Settings", comment: "Button title Product Settings in Edit Product More Options Action Sheet")
    static let cancel = NSLocalizedString("Cancel", comment: "Button title Cancel in Edit Product More Options Action Sheet")
    static let duplicate = NSLocalizedString("Duplicate", comment: "Button title to duplicate a product in Product More Options Action Sheet")
}
