//
//  DefaultEventFormTableViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import UIKit
import FiableRedux
import FiableFoundation

/// The Product form contains 2 sections: primary fields, and details.
struct DefaultEventFormTableViewModel: EventFormTableViewModel {

    private(set) var sections: [EventFormSection] = []

    private let featureFlagService: FeatureFlagService

    init(
        product: EventFormDataModel,
        actionsFactory: EventFormActionsFactoryProtocol,
        featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService
    ) {
        self.featureFlagService = featureFlagService
        configureSections(product: product, actionsFactory: actionsFactory)
    }
}

private extension DefaultEventFormTableViewModel {
    mutating func configureSections(
        product: EventFormDataModel,
        actionsFactory: EventFormActionsFactoryProtocol
    ) {
        sections = [.primaryFields(
            rows: primaryFieldRows(
                product: product,
                actions: actionsFactory.primarySectionActions()
            )),
            .settings(rows: settingsRows(productModel: product, actions: actionsFactory.settingsSectionActions()))]
            .filter { $0.isNotEmpty }
    }

    func primaryFieldRows(product: EventFormDataModel, actions: [EventFormEditAction]) -> [EventFormSection.PrimaryFieldRow] {
        actions.map { action -> [EventFormSection.PrimaryFieldRow] in
            switch action {
         
            case .name(let editable):
                return [.name(name: product.name, isEditable: editable, eventStatus: .published)]

            
            default:
                fatalError("Unexpected action in the primary section: \(action)")
            }
        }.reduce([], +)
    }

    func settingsRows(productModel product: EventFormDataModel, actions: [EventFormEditAction]) -> [EventFormSection.SettingsRow] {
        switch product {
        case let product as EditableEventModel:
            return settingsRows(product: product, actions: actions)
        default:
            fatalError("Unexpected product form data model: \(type(of: product))")
        }
    }

    func settingsRows(product: EditableEventModel, actions: [EventFormEditAction]) -> [EventFormSection.SettingsRow] {
        return actions.compactMap { action in
            switch action {
           
            case .productType(let editable):
                return .productType(viewModel: productTypeRow(product: product, isEditable: editable), isEditable: editable)
           
            case .categories(let editable):
                return .categories(viewModel: categoriesRow(product: product.product, isEditable: editable), isEditable: editable)
         
            default:
                assertionFailure("Unexpected action in the settings section: \(action)")
                return nil
            }
        }
    }
}

private extension DefaultEventFormTableViewModel {
    
    func productTypeRow(product: EventFormDataModel, isEditable: Bool) -> EventFormSection.SettingsRow.ViewModel {
        let icon = UIImage.productImage
        let title = Localization.productTypeTitle

        let details: String = product.productType?.name ?? ""

        return EventFormSection.SettingsRow.ViewModel(icon: icon,
                                                        title: title,
                                                        details: details,
                                                        isActionable: isEditable)
    }

    func categoriesRow(product: MateEvent, isEditable: Bool) -> EventFormSection.SettingsRow.ViewModel {
        let icon = UIImage.categoriesIcon
        let title = "Localization.categoriesTitle"
        let details = "product.categoriesDescription() ?? Localization.categoriesPlaceholder"
        return EventFormSection.SettingsRow.ViewModel(icon: icon, title: title, details: details, isActionable: isEditable)
    }
}


private extension DefaultEventFormTableViewModel {
  
      
    enum Localization {
        static let productTypeTitle = NSLocalizedString(
            "Product type",
            comment: "Title of the Product Type row on Product main screen"
        )
           
        static let categoriesTitle = NSLocalizedString("Categories", comment: "")
          
        // Categories
        static let categoriesPlaceholder = NSLocalizedString(
            "No category selected",
            comment: "Placeholder of the Product Categories row on Product main screen"
        )
    }
}
