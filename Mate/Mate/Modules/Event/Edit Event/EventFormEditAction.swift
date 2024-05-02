//
//  EventFormEditAction.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import FiableRedux

/// Edit actions in the product form. Each action allows the user to edit a subset of product properties.
enum EventFormEditAction: Equatable {
    case name(editable: Bool)
    case productType(editable: Bool)
    case categories(editable: Bool)
    case date(editable: Bool)
    case google_place_id(editable: Bool)
}

/// Creates actions for different sections/UI on the product form.
struct EventFormActionsFactory: EventFormActionsFactoryProtocol {

    private let product: EditableEventModel
    private let formType: ProductFormType
    private let editable: Bool


    // TODO: Remove default parameter
    init(
        product: EditableEventModel,
        formType: ProductFormType,
        addOnsFeatureEnabled: Bool = true
    ) {
        self.product = product
        self.formType = formType
        self.editable = formType != .readonly
    }

    /// Returns an array of actions that are visible in the product form primary section.
    func primarySectionActions() -> [EventFormEditAction] {
        let shouldShowImagesRow = false//editable || product.images.isNotEmpty
        let shouldShowDescriptionRow = false//editable || product.description?.isNotEmpty == true
        let canEditProductType = editable

        let actions: [EventFormEditAction?] = [
            .name(editable: editable)
        ]
        return actions.compactMap { $0 }
    }

    /// Returns an array of actions that are visible in the product form settings section.
    func settingsSectionActions() -> [EventFormEditAction] {
        return visibleSettingsSectionActions()
    }

    /// Returns an array of actions that are visible in the product form bottom sheet.
    func bottomSheetActions() -> [EventFormBottomSheetAction] {
        guard editable else {
            return []
        }
        return allSettingsSectionActions().filter { settingsSectionActions().contains($0) == false }
            .compactMap { EventFormBottomSheetAction(productFormAction: $0) }
    }
}

private extension EventFormActionsFactory {
    /// All the editable actions in the settings section given the product and feature switches.
    func allSettingsSectionActions() -> [EventFormEditAction] {
        return allSettingsSectionActionsForNonCoreProduct()
//        switch product.product.productType {
//        case .simple:
//            return allSettingsSectionActionsForSimpleProduct()
//        case .grouped:
//            return allSettingsSectionActionsForGroupedProduct()
//        case .variable:
//            return allSettingsSectionActionsForVariableProduct()
//        case .bundle:
//            return allSettingsSectionActionsForBundleProduct()
//        case .composite:
//            return allSettingsSectionActionsForCompositeProduct()
//        case .subscription:
//            return allSettingsSectionActionsForSubscriptionProduct()
//        case .variableSubscription:
//            return allSettingsSectionActionsForVariableSubscriptionProduct()
//        default:
//            return allSettingsSectionActionsForNonCoreProduct()
//        }
    }

    func allSettingsSectionActionsForSimpleProduct() -> [EventFormEditAction] {
        let shouldShowReviewsRow = false
        let canEditProductType = editable

        let actions: [EventFormEditAction?] = [
            .categories(editable: editable)
        ]
        return actions.compactMap { $0 }
    }


    func allSettingsSectionActionsForNonCoreProduct() -> [EventFormEditAction] {
        let shouldShowPriceSettingsRow = true//product.regularPrice.isNilOrEmpty == false
        let shouldShowReviewsRow = true//product.reviewsAllowed
        let shouldShowQuantityRulesRow = true //isMinMaxQuantitiesEnabled && product.hasQuantityRules

        let actions: [EventFormEditAction?] = [
            .categories(editable: editable)
        ]
        return actions.compactMap { $0 }
    }
}

private extension EventFormActionsFactory {
    func visibleSettingsSectionActions() -> [EventFormEditAction] {
        return allSettingsSectionActions().compactMap({ $0 }).filter({ isVisibleInSettingsSection(action: $0) })
    }

    func isVisibleInSettingsSection(action: EventFormEditAction) -> Bool {
        switch action {
      
        case .productType:
            // The product type action is always visible in the settings section.
            return true
//        case .categories:
//            return product.product.category?.name.isEmpty ?? false

        default:
            return false
        }
    }
}
