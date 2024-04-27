//
//  ProductFormViewModelProtocol.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Combine
import FiableRedux

/// The type of product form: adding a new one or editing an existing one.
enum ProductFormType {
    case add
    case edit
    case readonly
}

/// The type of action that can be performed in the product.
enum ActionButtonType {
    case preview
    case publish
    case save
    case more
    case share
}

/// The type of save message when saving a product.
enum SaveMessageType {
    case publish
    case save
    case saveVariation
    case duplicate
}


/// A view model for `EventFormViewController` to add/edit a generic product model (e.g. `Event``).
///
protocol EventFormViewModelProtocol {
//    associatedtype ProductModel: ProductFormDataModel & TaxClassRequestable
    associatedtype EventModel: EventFormDataModel

    /// Emits product on change, except when the product name is the only change (`productName` is emitted for this case).
    var observableProduct: AnyPublisher<EventModel, Never> { get }

    /// The type of form: adding a new product or editing an existing product.
    var formType: ProductFormType { get }

    /// Emits product name on change. If the name is not editable (e.g. when the product model is `ProductVariation`), `nil` is returned.
    var productName: AnyPublisher<String, Never>? { get }

    /// Emits a boolean of whether the product has unsaved changes for remote update.
    var isUpdateEnabled: AnyPublisher<Bool, Never> { get }

    /// Emits a void value informing when there is a new variation price state available
//    var newVariationsPrice: AnyPublisher<Void, Never> { get }

    /// Emits a void value informing when Blaze eligibility is computed
//    var blazeEligibilityUpdate: AnyPublisher<Void, Never> { get }

    /// Creates actions available on the bottom sheet.
    var actionsFactory: EventFormActionsFactoryProtocol { get }

    /// The latest product value.
    var productModel: EventModel { get }

    /// The original product value.
    var originalProductModel: EventModel { get }

    /// The action buttons that should be rendered in the navigation bar.
    var actionButtons: [ActionButtonType] { get }

    /// Whether the "Promote with Blaze" button should show Blaze intro view first or not when tapped.
//    var shouldShowBlazeIntroView: Bool { get }

    // Unsaved changes

    func hasUnsavedChanges() -> Bool

    // More menu

    func canSaveAsDraft() -> Bool

    func canShowPublishOption() -> Bool

    func canEditProductSettings() -> Bool

    func canViewProductInStore() -> Bool

    func canShareProduct() -> Bool

//    func canPromoteWithBlaze() -> Bool

    func canDeleteProduct() -> Bool

    func canDuplicateProduct() -> Bool

    // Update actions

//    func updateName(_ name: String)

//    func updateDescription(_ newDescription: String)

//    func updateProductType(productType: BottomSheetProductType)

//    func updateProductCategories(_ categories: [ProductCategory])

//    func updateShortDescription(_ shortDescription: String)

//    func updateStatus(_ isEnabled: Bool)

    // Remote action

    /// Creates/updates a product remotely given an optional product status to override.
    /// - Parameters:
    ///   - status: If non-nil, the given status overrides the latest product's status to be saved remotely.
    ///   - onCompletion: Called when the product is saved remotely.
//    func saveProductRemotely(status: ProductStatus?, onCompletion: @escaping (Result<ProductModel, ProductUpdateError>) -> Void)

//    func deleteProductRemotely(onCompletion: @escaping (Result<Void, ProductUpdateError>) -> Void)

//    func duplicateProduct(onCompletion: @escaping (Result<ProductModel, ProductUpdateError>) -> Void)

    // Tracking

    /// Tracks when the product form is loaded
//    func trackProductFormLoaded()
}

extension EventFormViewModelProtocol {
    func shouldShowMoreOptionsMenu() -> Bool {
        canSaveAsDraft() || canEditProductSettings() || canViewProductInStore() || canShareProduct() || canDeleteProduct()
    }

    /// Returns `.publish` when the product does not exists remotely and it's gonna be published for the first time.
    /// Returns `.publish` when the product is going to be published from a different status (eg: from draft).
    /// Returns `.saveVariation` when save variation
    /// Returns `.save` for any other case.
    ///
//    func saveMessageType(for productStatus: ProductStatus) -> SaveMessageType {
//        switch productStatus {
//        case .published where !productModel.existsRemotely || originalProductModel.status != .published:
//            return .publish
//        default:
//            if self is ProductVariationFormViewModel {
//                return .saveVariation
//            }
//            else {
//                return .save
//            }
//        }
//    }

    /// Whether the Preview button should be enabled, when it's available in the navigation bar.
    /// Returns `false` when it's a new blank product without any changes.
    ///
    func shouldEnablePreviewButton() -> Bool {
        switch formType {
        case .add:
            return hasUnsavedChanges()
        case .edit, .readonly:
            return true
        }
    }
}

