//
//  AddEventCoordinator.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import UIKit
import FiableRedux
import FiableFoundation
import MateStorage
import MateNetworking

/// Controls navigation for the flow to add a product given a navigation controller.
/// This class is not meant to be retained so that its life cycle is throughout the navigation. Example usage:
///
/// let coordinator = AddProductCoordinator(...)
/// coordinator.start()
///
final class AddEventCoordinator: Coordinator {
    /// Navigation source to the add product flow.
    enum Source {
        /// Initiated from the products tab.
        case productsTab
        /// Initiated from the store onboarding card in the dashboard.
        case storeOnboarding
        /// Initiated from the product description AI announcement modal in the dashboard.
        case productDescriptionAIAnnouncementModal
        /// Initiated from the campaign creation entry point when there is no product in the store.
        case blazeCampaignCreation
    }

    /// Source view that initiates product creation for the action sheet to point to.
    enum SourceView {
        case barButtonItem(UIBarButtonItem)
        case view(UIView)
    }

    let navigationController: UINavigationController

    private let source: Source
    private let sourceBarButtonItem: UIBarButtonItem?
    private let sourceView: UIView?
    private let storage: StorageManagerType
    private let isFirstProduct: Bool
    private let analytics: Analytics
    private let navigateToProductForm: ((UIViewController) -> Void)?
    private let onDeleteCompletion: () -> Void

    /// ResultController to to track the current product count.

    /// Assign this closure to be notified when a new product is saved remotely
    ///
    var onProductCreated: (MateEvent) -> Void = { _ in }

    private lazy var productCreationAISurveyPresenter: BottomSheetPresenter = {
        BottomSheetPresenter(configure: { bottomSheet in
            var sheet = bottomSheet
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.prefersGrabberVisible = false
            sheet.detents = [.medium()]
        })
    }()


    /// - Parameters:
    ///   - navigateToProductForm: Optional custom navigation when showing the product form for the new product.
    init(
         source: Source,
         sourceView: SourceView?,
         sourceNavigationController: UINavigationController,
         storage: StorageManagerType = ServiceLocator.storageManager,
         analytics: Analytics = ServiceLocator.analytics,
         isFirstProduct: Bool,
         navigateToProductForm: ((UIViewController) -> Void)? = nil,
         onDeleteCompletion: @escaping () -> Void = {}
    ) {
        self.source = source
        switch sourceView {
            case let .barButtonItem(barButtonItem):
                self.sourceBarButtonItem = barButtonItem
                self.sourceView = nil
            case let .view(view):
                self.sourceBarButtonItem = nil
                self.sourceView = view
            case .none:
                self.sourceBarButtonItem = nil
                self.sourceView = nil
        }
        self.navigationController = sourceNavigationController
        self.storage = storage
        self.analytics = analytics
        self.isFirstProduct = isFirstProduct
        self.navigateToProductForm = navigateToProductForm
        self.onDeleteCompletion = onDeleteCompletion
    }

    func start() {
        if shouldSkipBottomSheet {
            presentEventForm(bottomSheetProductType: nil)
        } else  {
            presentProductCreationTypeBottomSheet()
        }
    }
}

// MARK: Navigation
private extension AddEventCoordinator {

    /// Whether the action sheet with the option for product creation with AI should be presented.
    ///
    var shouldShowAIActionSheet: Bool {
        return false//addProductWithAIEligibilityChecker.isEligible
    }

    /// Defines if the product creation bottom sheet should be presented.
    /// Currently returns `true` when the store is eligible for displaying template options.
    ///
    var shouldPresentProductCreationBottomSheet: Bool {
        return true//isTemplateOptionsEligible
    }

    /// Defines if it should skip the bottom sheet before the product form is shown.
    /// Currently returns `true` when the source is product description AI announcement modal.
    ///
    var shouldSkipBottomSheet: Bool {
        return false//source == .productDescriptionAIAnnouncementModal
    }


    /// Presents a bottom sheet for users to choose if they want a create a product manually or via a template.
    ///
    func presentProductCreationTypeBottomSheet() {
        let title = NSLocalizedString("Add a product",
                                      comment: "Message title of bottom sheet for selecting a template or manual product")
        let subtitle = NSLocalizedString("How do you want to start?",
                                         comment: "Message subtitle of bottom sheet for selecting a template or manual product")
        let viewProperties = BottomSheetListSelectorViewProperties(title: title, subtitle: subtitle)
        let command = ProductCreationTypeSelectorCommand { selectedCreationType in
//            self.trackProductCreationType(selectedCreationType)
            self.presentProductTypeBottomSheet(creationType: selectedCreationType)
        }
        let productTypesListPresenter = BottomSheetListSelectorPresenter(viewProperties: viewProperties, command: command)
        productTypesListPresenter.show(
            from: navigationController,
            sourceView: sourceView,
            sourceBarButtonItem: sourceBarButtonItem,
            arrowDirections: .any
        )
    }


    /// Presents a new product based on the provided bottom sheet type.
    ///
    func presentEventForm(bottomSheetProductType: BottomSheetProductType?) {
        guard let event = EventFactory().createNewEvent(type: bottomSheetProductType, isVirtual:true) else {
            assertionFailure("Unable to create event of type: ")
            return
        }
        presentProduct(event)
    }


    /// Presents an general error notice using the system notice presenter.
    ///
    func presentErrorNotice() {
        let notice = Notice(title: NSLocalizedString("There was a problem creating the template product.",
                                                     comment: "Title for the error notice when creating a template product"))
        ServiceLocator.noticePresenter.enqueue(notice: notice)
    }


    /// Presents a bottom sheet for users to choose if what kind of product they want to create.
    ///
    func presentProductTypeBottomSheet(creationType: ProductCreationType) {
        let title: String? = {
            guard creationType == .template else { return nil }
            return NSLocalizedString("Choose a template", comment: "Message title of bottom sheet for selecting a template or manual product")
        }()
        let subtitle = NSLocalizedString("Select a product type",
                                         comment: "Message subtitle of bottom sheet for selecting a product type to create a product")
        let viewProperties = BottomSheetListSelectorViewProperties(title: title, subtitle: subtitle)
        let command = ProductTypeBottomSheetListSelectorCommand(selected: nil) { [weak self] selectedBottomSheetProductType in
            guard let self else { return }
           
            self.navigationController.dismiss(animated: true) {
                switch creationType {
                case .manual:
                    self.presentProductForm(bottomSheetProductType: selectedBottomSheetProductType)
                case .template:
                    print("sss")
//                    self.createAndPresentTemplate(productType: selectedBottomSheetProductType)
                }
            }
        }

        switch creationType {
        case .template:
            command.data = [.football,.basketball, .tenins]
        case .manual:
            command.data = []
        }

        let productTypesListPresenter = BottomSheetListSelectorPresenter(viewProperties: viewProperties, command: command)

        // `topmostPresentedViewController` is used because another bottom sheet could have been presented before.
        productTypesListPresenter.show(from: navigationController.topmostPresentedViewController,
                                       sourceView: sourceView,
                                       sourceBarButtonItem: sourceBarButtonItem,
                                       arrowDirections: .any)
    }
    
    /// Presents a new product based on the provided bottom sheet type.
    ///
    func presentProductForm(bottomSheetProductType: BottomSheetProductType) {
        guard let product = EventFactory().createNewEvent(
            type: bottomSheetProductType,
            isVirtual: false
        ) else {
            assertionFailure("Unable to create product of type: \(bottomSheetProductType)")
            return
        }
        presentProduct(product)
    }

    /// Presents a product onto the current navigation stack.
    ///
    func presentProduct(_ product: MateEvent, formType: ProductFormType = .add, isAIContent: Bool = false) {
//        let model = EditableProductModel(product: product)
//                        
//
//        let viewModel = ProductFormViewModel(product: model,
//                                             formType: formType)
//        
//        viewModel.onProductCreated = { [weak self] product in
//            guard let self else { return }
//            self.onProductCreated(product)
//    
//        }
//        let viewController = ProductFormViewController(viewModel: viewModel,
//                                                       isAIContent: isAIContent,
//                                                       presentationStyle: .navigationStack,
//                                                       onDeleteCompletion: onDeleteCompletion)
//        // Since the Add Product UI could hold local changes, disables the bottom bar (tab bar) to simplify app states.
//        viewController.hidesBottomBarWhenPushed = true
//        if let navigateToProductForm {
//            navigateToProductForm(viewController)
//        } else {
//            navigationController.pushViewController(viewController, animated: true)
//        }
    }


    func buildBottomSheetPresenter() -> BottomSheetPresenter {
        BottomSheetPresenter(configure: { bottomSheet in
            var sheet = bottomSheet
            sheet.prefersEdgeAttachedInCompactHeight = true

            // Sets detents for the sheet.
            // Skips large detent if the device is iPad.
            let traitCollection = UIScreen.main.traitCollection
            let isIPad = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
            if isIPad {
                sheet.detents = [.medium()]
            } else {
                sheet.detents = [.large(), .medium()]
            }
            sheet.prefersGrabberVisible = !isIPad
        })
    }
}



///
public enum ProductCreationType: Equatable {
    case template
    case manual

    /// Title shown on the action sheet.
    ///
    var actionSheetTitle: String {
        switch self {
        case .template:
            return NSLocalizedString("Start with a template", comment: "Title for the option to create a template product")
        case .manual:
            return NSLocalizedString("Add manually", comment: "Title for the option to create product manually")
        }
    }

    /// Description shown on the action sheet.
    ///
    var actionSheetDescription: String {
        switch self {
        case .template:
            return NSLocalizedString("Use a template to create physical, virtual, and variable products. You can edit it as you go.",
                                     comment: "Description for the option to create a template product")
        case .manual:
            return NSLocalizedString("Add a product manually.",
                                     comment: "Description for the option to create product manually")
        }
    }

    /// Image shown on the action sheet.
    ///
    var actionSheetImage: UIImage {
        switch self {
        case .template:
            return .sitesImage
        case .manual:
            return .addOutlineImage
        }
    }
}

/// Selector command for selecting a template product.
///
final class ProductCreationTypeSelectorCommand: BottomSheetListSelectorCommand {
    typealias Model = ProductCreationType
    typealias Cell = ImageAndTitleAndTextTableViewCell

    var data: [ProductCreationType] = [.template, .manual]

    var selected: ProductCreationType? = nil

    private let onSelection: (ProductCreationType) -> Void

    init(onSelection: @escaping (ProductCreationType) -> Void) {
        self.onSelection = onSelection
    }

    func configureCell(cell: ImageAndTitleAndTextTableViewCell, model: ProductCreationType) {
        let viewModel = ImageAndTitleAndTextTableViewCell.ViewModel(title: model.actionSheetTitle,
                                                                    text: model.actionSheetDescription,
                                                                    image: model.actionSheetImage,
                                                                    imageTintColor: .gray(.shade20),
                                                                    numberOfLinesForText: 0)
        cell.updateUI(viewModel: viewModel)
    }

    func handleSelectedChange(selected: ProductCreationType) {
        onSelection(selected)
    }

    func isSelected(model: ProductCreationType) -> Bool {
        return model == selected
    }
}
