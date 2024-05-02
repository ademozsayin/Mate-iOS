//
//  EventFormTableViewDataSource.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import UIKit
import FiableRedux
import FiableFoundation

private extension EventFormSection.SettingsRow.ViewModel {
    func toCellViewModel() -> ImageAndTitleAndTextTableViewCell.ViewModel {
        return ImageAndTitleAndTextTableViewCell.ViewModel(title: title,
                                                           text: details,
                                                           textTintColor: tintColor,
                                                           image: icon,
                                                           imageTintColor: tintColor ?? .textSubtle,
                                                           numberOfLinesForText: numberOfLinesForDetails,
                                                           isActionable: isActionable,
                                                           showsDisclosureIndicator: isActionable,
                                                           showsSeparator: !hideSeparator)
    }
}

/// Configures the sections and rows of Event form table view based on the view model.
///
final class EventFormTableViewDataSource: NSObject {
    private let viewModel: EventFormTableViewModel
    private var onNameChange: ((_ name: String?) -> Void)?
    private var onStatusChange: ((_ isEnabled: Bool) -> Void)?
    private var onAddImage: (() -> Void)?


    var openLinkedProductsAction: (() -> Void)?
    var reloadLinkedPromoAction: (() -> Void)?
    var descriptionAIAction: (() -> Void)?
    var openAILegalPageAction: ((URL) -> Void)?

    init(
        viewModel: EventFormTableViewModel
    ) {
        self.viewModel = viewModel
        super.init()
    }

    func configureActions(
        onNameChange: ((_ name: String?) -> Void)?,
        onStatusChange: ((_ isEnabled: Bool) -> Void)?
    ) {
        self.onNameChange = onNameChange
        self.onStatusChange = onStatusChange
    }
}

extension EventFormTableViewDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = viewModel.sections[section]
        switch section {
        case .primaryFields(let rows):
            return rows.count
        case .settings(let rows):
            return rows.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = viewModel.sections[indexPath.section]
        let reuseIdentifier = section.reuseIdentifier(at: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        configure(cell, section: section, indexPath: indexPath)
        return cell
    }
}

private extension EventFormTableViewDataSource {
    func configure(_ cell: UITableViewCell, section: EventFormSection, indexPath: IndexPath) {
        switch section {
        case .primaryFields(let rows):
            configureCellInPrimaryFieldsSection(cell, row: rows[indexPath.row])
        case .settings(let rows):
            configureCellInSettingsFieldsSection(cell, row: rows[indexPath.row])
        }
    }
}

// MARK: Configure rows in Primary Fields Section
//
private extension EventFormTableViewDataSource {
    func configureCellInPrimaryFieldsSection(_ cell: UITableViewCell, row: EventFormSection.PrimaryFieldRow) {
        switch row {
        case .name(let name, let editable, let productStatus):
            configureName(cell: cell, name: name, isEditable: editable, productStatus: productStatus)
        case .variationName(let name):
            configureReadonlyName(cell: cell, name: name)
        case .description(let description, let editable, let isAIEnabled):
            configureDescription(cell: cell, description: description, isEditable: editable, isAIEnabled: isAIEnabled)
        case .separator:
            configureSeparator(cell: cell)
        }
    }

    func configureName(cell: UITableViewCell, name: String?, isEditable: Bool, productStatus: EventStatus) {
        if isEditable {
            configureEditableName(cell: cell, name: name, productStatus: productStatus)
        } else {
            configureReadonlyName(cell: cell, name: name ?? "")
        }
    }

    func configureEditableName(cell: UITableViewCell, name: String?, productStatus: EventStatus) {
        guard let cell = cell as? LabeledTextViewTableViewCell else {
            fatalError()
        }

        cell.accessoryType = .none
        cell.accessibilityIdentifier = "product-title"

        let placeholder = NSLocalizedString("Title", comment: "Placeholder in the Product Title row on Product form screen.")

        let cellViewModel = LabeledTextViewTableViewCell.ViewModel(text: name,
                                                                   productStatus: productStatus,
                                                                   placeholder: placeholder,
                                                                   textViewMinimumHeight: 10.0,
                                                                   isScrollEnabled: false,
                                                                   onNameChange: { [weak self] (newName) in self?.onNameChange?(newName) },
                                                                   style: .headline)
        cell.configure(with: cellViewModel)
        cell.accessibilityLabel = NSLocalizedString(
            "Title of the product",
            comment: "VoiceOver accessibility hint, informing the user about the title of a product in product detail screen."
        )
    }

    func configureReadonlyName(cell: UITableViewCell, name: String) {
        guard let cell = cell as? BasicTableViewCell else {
            fatalError()
        }

        cell.accessoryType = .none
        cell.textLabel?.text = name
        cell.textLabel?.applyHeadlineStyle()
        cell.textLabel?.textColor = .text
        cell.textLabel?.numberOfLines = 0
    }

    func configureDescription(cell: UITableViewCell, description: String?, isEditable: Bool, isAIEnabled: Bool) {
        if let description = description, description.isEmpty == false {
            guard let cell = cell as? ImageAndTitleAndTextTableViewCell else {
                fatalError()
            }
            let title = NSLocalizedString("Description",
                                          comment: "Title in the Product description row on Product form screen when the description is non-empty.")
            let viewModel = ImageAndTitleAndTextTableViewCell.ViewModel(title: title, text: description, isActionable: isEditable)
            cell.updateUI(viewModel: viewModel)
        } else {
            guard let cell = cell as? BasicTableViewCell else {
                fatalError()
            }
            let placeholder = NSLocalizedString("Describe your product", comment: "Placeholder in the Product description row on Product form screen.")
            cell.textLabel?.text = placeholder
            cell.textLabel?.applyBodyStyle()
            cell.textLabel?.textColor = .textSubtle
            cell.accessibilityIdentifier = "product-description"
        }
        if isEditable {
            cell.accessoryType = .disclosureIndicator
        }
        if isAIEnabled {
            cell.hideSeparator()
        }
    }

    func configureSeparator(cell: UITableViewCell) {
        guard let cell = cell as? SpacerTableViewCell else {
            fatalError("Unexpected table view cell for the separator cell")
        }
        cell.selectionStyle = .none
        cell.backgroundColor = .listBackground
        cell.hideSeparator()
        cell.configure(height: Constants.settingsHeaderHeight)
    }
}

// MARK: Configure rows in Settings Fields Section
//
private extension EventFormTableViewDataSource {
    func configureCellInSettingsFieldsSection(_ cell: UITableViewCell, row: EventFormSection.SettingsRow) {
        switch row {
        case .price(let viewModel, _),
             .inventory(let viewModel, _),
             .productType(let viewModel, _),
             .shipping(let viewModel, _),
             .addOns(let viewModel, _),
             .categories(let viewModel, _),
             .tags(let viewModel, _),
             .shortDescription(let viewModel, _),
             .externalURL(let viewModel, _),
             .sku(let viewModel, _),
             .groupedProducts(let viewModel, _),
             .downloadableFiles(let viewModel, _),
             .linkedProducts(let viewModel, _),
             .variations(let viewModel),
             .attributes(let viewModel, _),
             .bundledProducts(let viewModel, _),
             .components(let viewModel, _),
             .subscriptionFreeTrial(let viewModel, _),
             .subscriptionExpiry(let viewModel, _),
             .quantityRules(let viewModel):
            configureSettings(cell: cell, viewModel: viewModel)
        case .reviews(let viewModel, let ratingCount, let averageRating):
            configureReviews(cell: cell, viewModel: viewModel, ratingCount: ratingCount, averageRating: averageRating)
        case .status(let viewModel, _):
            configureSettingsRowWithASwitch(cell: cell, viewModel: viewModel)
        case .noPriceWarning(let viewModel),
             .noVariationsWarning(let viewModel):
            configureWarningRow(cell: cell, viewModel: viewModel)
        }
    }

    func configureSettings(cell: UITableViewCell, viewModel: EventFormSection.SettingsRow.ViewModel) {
        guard let cell = cell as? ImageAndTitleAndTextTableViewCell else {
            fatalError()
        }
        cell.updateUI(viewModel: viewModel.toCellViewModel())
    }

    func configureReviews(
        cell: UITableViewCell,
        viewModel: EventFormSection.SettingsRow.ViewModel,
        ratingCount: Int,
        averageRating: String
    ) {
        guard let cell = cell as? ProductReviewsTableViewCell else {
            fatalError()
        }

        cell.configure(image: viewModel.icon,
                       title: viewModel.title ?? "",
                       details: viewModel.details ?? "",
                       ratingCount: ratingCount,
                       averageRating: averageRating)
        cell.accessoryType = .disclosureIndicator
        cell.accessibilityIdentifier = "product-review-cell"
    }

    func configureSettingsRowWithASwitch(cell: UITableViewCell, viewModel: EventFormSection.SettingsRow.SwitchableViewModel) {
        guard let cell = cell as? ImageAndTitleAndTextTableViewCell else {
            fatalError()
        }

        let switchableViewModel = ImageAndTitleAndTextTableViewCell.SwitchableViewModel(
            viewModel: viewModel.viewModel.toCellViewModel(),
            isSwitchOn: viewModel.isSwitchOn,
            isActionable: viewModel.isActionable
        ) { [weak self] isSwitchOn in
            self?.onStatusChange?(isSwitchOn)
        }
        cell.updateUI(switchableViewModel: switchableViewModel)
    }

    func configureWarningRow(cell warningCell: UITableViewCell, viewModel: EventFormSection.SettingsRow.WarningViewModel) {
        guard let cell = warningCell as? ImageAndTitleAndTextTableViewCell else {
            fatalError("Unexpected cell type \(warningCell) for view model: \(viewModel)")
        }
        cell.update(with: .warning,
                    data: .init(title: viewModel.title,
                                image: viewModel.icon,
                                numberOfLinesForTitle: 0,
                                isActionable: false,
                                showsSeparator: false))
    }
}

private extension EventFormTableViewDataSource {
    enum Constants {
        static let legalURL = URL(string: "https://automattic.com/ai-guidelines/")!
        static let learnMoreTextHeight: CGFloat = 16
        static let learnMoreTextInsets: UIEdgeInsets = .init(top: 4, left: 0, bottom: 4, right: 0)
        static let settingsHeaderHeight = CGFloat(16)
        static let blazeButtonIconSize = CGSize(width: 20, height: 20)
    }
    enum Localization {
        static let legalText = NSLocalizedString(
            "Powered by AI. %1$@.",
            comment: "Label to indicate AI-generated content in the product detail screen. " +
            "Reads: Powered by AI. Learn more."
        )
        static let learnMore = NSLocalizedString(
            "Learn more",
            comment: "Title for the link to open the legal URL for AI-generated content in the product detail screen"
        )
    }
}
