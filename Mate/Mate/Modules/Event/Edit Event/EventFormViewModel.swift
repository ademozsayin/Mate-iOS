//
//  EventFormViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import Combine
import FiableRedux

import MateStorage

/// Provides data for product form UI, and handles product editing actions.
final class EventFormViewModel: EventFormViewModelProtocol {
   
    typealias ProductModel = EditableEventModel

    /// Emits product on change, except when the product name is the only change (`productName` is emitted for this case).
    var observableProduct: AnyPublisher<EditableEventModel, Never> {
        productSubject.eraseToAnyPublisher()
    }

    /// Emits product name on change.
    var productName: AnyPublisher<String, Never>? {
        productNameSubject.eraseToAnyPublisher()
    }

    /// Emits a boolean of whether the product has unsaved changes for remote update.
    var isUpdateEnabled: AnyPublisher<Bool, Never> {
        isUpdateEnabledSubject.eraseToAnyPublisher()
    }

    /// The latest product value.
    var productModel: EditableEventModel {
        product
    }

    /// The original product value.
    var originalProductModel: EditableEventModel {
        originalProduct
    }

    /// The form type could change from .add to .edit after creation.
    private(set) var formType: ProductFormType

    /// Creates actions available on the bottom sheet.
    private(set) var actionsFactory: EventFormActionsFactoryProtocol

    private let productSubject: PassthroughSubject<EditableEventModel, Never> = PassthroughSubject<EditableEventModel, Never>()
    private let productNameSubject: PassthroughSubject<String, Never> = PassthroughSubject<String, Never>()
    private let isUpdateEnabledSubject: PassthroughSubject<Bool, Never> = PassthroughSubject<Bool, Never>()

    /// The product model before any potential edits; reset after a remote update.
    private var originalProduct: EditableEventModel {
        didSet {
            product = originalProduct
        }
    }

    /// The product model with potential edits; reset after a remote update.
    private var product: EditableEventModel {
        didSet {
            guard product != oldValue else {
                return
            }
        }
    }

    /// The action buttons that should be rendered in the navigation bar.
    var actionButtons: [ActionButtonType] {
        // Figure out main action button first
        var buttons: [ActionButtonType] = {
            switch (formType,
                    originalProductModel.status,
                    productModel.status,
                    originalProduct.product.existsRemotely,
                    hasUnsavedChanges()) {
            case (.add, .published, .published, false, _): // New product with publish status
                return [.publish]

            case (.add, .published, _, false, _): // New product with a different status
                return [.save] // And publish in more

            case (.edit, .published, _, true, true): // Existing published product with changes
                return [.save]

            case (.edit, .published, _, true, false): // Existing published product with no changes
                return []

            case (.edit, _, _, true, true): // Any other existing product with changes
                return [.save] // And publish in more

            case (.edit, _, _, true, false): // Any other existing product with no changes
                return [.publish]

            case (.readonly, _, _, _, _): // Any product on readonly mode
                 return []

            default: // Impossible cases
                return []
            }
        }()

        // The `frame_nonce` value must be stored for the preview to be displayed
        if canSaveAsDraft() || originalProductModel.status == .draft {
            buttons.insert(.preview, at: 0)
        }

        // Add more button if needed
        if shouldShowMoreOptionsMenu() {
            buttons.append(.more)
        }

        // Share button if up to one button is visible.
        if canShareProduct() && buttons.count <= 1 {
            buttons.insert(.share, at: 0)
        }

        return buttons
    }

    private var cancellable: AnyCancellable?

    private let stores: StoresManager

    /// Assign this closure to be notified when a new product is saved remotely
    ///
    var onProductCreated: (MateEvent) -> Void = { _ in }

    /// Keeps a strong reference to the use case to wait for callback closures.
    ///
//    private lazy var remoteActionUseCase = ProductFormRemoteActionUseCase(stores: stores)

    init(product: EditableEventModel,
         formType: ProductFormType,
         stores: StoresManager = ServiceLocator.stores
    ) {
        self.formType = formType
        self.originalProduct = product
        self.product = product
        self.actionsFactory = EventFormActionsFactory(product: product, formType: formType)
        self.stores = stores

    }

    deinit {
        cancellable?.cancel()
    }
    
    func hasUnsavedChanges() -> Bool {
        let hasProductChangesExcludingImages = product.product.copy() != originalProduct.product.copy()     
        return hasProductChangesExcludingImages
    }
}

// MARK: - More menu
//
extension EventFormViewModel {

    /// Show publish button if the product can be published and the publish button is not already part of the action buttons.
    ///
    func canShowPublishOption() -> Bool {
        let newProduct = formType == .add && !originalProduct.product.existsRemotely
        let existingUnpublishedProduct = formType == .edit && originalProduct.product.existsRemotely && originalProduct.status != .published

        let productCanBePublished = newProduct || existingUnpublishedProduct
        let publishIsNotAlreadyVisible = !actionButtons.contains(.publish)

        return productCanBePublished && publishIsNotAlreadyVisible
    }

    func canSaveAsDraft() -> Bool {
        formType == .add && productModel.status != .draft
    }

    func canEditProductSettings() -> Bool {
        formType != .readonly
    }

    func canViewProductInStore() -> Bool {
        originalProduct.product.status == .published && formType != .add
    }

    func canShareProduct() -> Bool {
//        let isSitePublic = stores.sessionManager.defaultSite?.isPublic == true
//        let productHasLinkToShare = URL(string: product.permalink) != nil
//       
        return formType != .add
    }


    func canDeleteProduct() -> Bool {
        formType == .edit
    }

    func canDuplicateProduct() -> Bool {
        formType == .edit
    }
}

// MARK: Action handling
//
extension EventFormViewModel {

}

// MARK: Remote actions
//
extension EventFormViewModel {
   
}

// MARK: Reset actions
//
extension EventFormViewModel {
    private func resetProduct(_ product: EditableEventModel) {
        originalProduct = product
    }
}

