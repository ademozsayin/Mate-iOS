import UIKit
import MateNetworking
import FiableFoundation

final class ProductsTabProductTableViewCell: UITableViewCell {
    private lazy var productImageView: UIImageView = {
        let image = UIImageView(frame: .zero)
        return image
    }()

    private var selectedProductImageOverlayView: UIView?

    /// ProductImageView.width == 0.1*Cell.width
    private var productImageViewRelationalWidthConstraint: NSLayoutConstraint?

    /// ProductImageView.height == Cell.height
    private var productImageViewFixedHeightConstraint: NSLayoutConstraint?

    private lazy var nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()

    private lazy var detailsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        return label
    }()

    /// We use a custom view instead of the default separator as it's width varies depending on the image size, which varies depending on the screen size.
    private let bottomBorderView: UIView = {
        return UIView(frame: .zero)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureBackground()
        configureSubviews()
        configureNameLabel()
        configureDetailsLabel()
        configureProductImageView()
        configureBottomBorderView()
        // From iOS 15.0, a focus effect will be applied automatically to a selected cell
        // modifying its style (e.g: by adding a border)
        focusEffect = nil
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Border color is not automatically updated on trait collection changes and thus manually updated here.
        productImageView.layer.borderColor = Colors.imageBorderColor.cgColor
    }

    override func updateConfiguration(using state: UICellConfigurationState) {
        super.updateConfiguration(using: state)
        updateDefaultBackgroundConfiguration(using: state)
    }
}

extension ProductsTabProductTableViewCell: SearchResultCell {
    typealias SearchModel = MateEvent

    func configureCell(searchModel: MateEvent) {
        update(
            viewModel: searchModel
//            imageService: searchModel.imageService
        )
    }

    static func register(for tableView: UITableView) {
        tableView.register(self)
    }
}

extension ProductsTabProductTableViewCell {
//    func update(viewModel: MateEvent, imageService: ImageService) {
    func update(viewModel: MateEvent) {
        nameLabel.text = viewModel.name
//        detailsLabel.attributedText = viewModel.address
        accessibilityIdentifier = viewModel.name

        productImageView.contentMode = .center
//        if viewModel.isDraggable {
//            configureProductImageViewForSmallIcons()
//            productImageView.image = .alignJustifyImage
//            productImageView.layer.borderWidth = 0
//        } else {
            configureProductImageViewForBigImages()
            productImageView.image = .productsTabProductCellPlaceholderImage
//            if let productURLString = viewModel.imageUrl {
//                imageService.downloadAndCacheImageForImageView(productImageView,
//                                                               with: productURLString,
//                                                               placeholder: .productsTabProductCellPlaceholderImage,
//                                                               progressBlock: nil) { [weak self] (image, error) in
//                                                                let success = image != nil && error == nil
//                                                                if success {
//                                                                    self?.productImageView.contentMode = .scaleAspectFill
//                                                                }
//                }
//            }
//        }

        // Selected state.
        let isSelected = false//viewModel.isSelected
        if isSelected {
            configureSelectedProductImageOverlayView()
        } else {
            selectedProductImageOverlayView?.removeFromSuperview()
            selectedProductImageOverlayView = nil
        }
    }

    func configureAccessoryDeleteButton(onTap: @escaping () -> Void) {
        let deleteButton = UIButton(type: .detailDisclosure)
        deleteButton.setImage(.deleteCellImage, for: .normal)
        deleteButton.tintColor = .systemColor(.tertiaryLabel)
        deleteButton.on(.touchUpInside) { _ in
            onTap()
        }
        accessoryView = deleteButton
    }
}

private extension ProductsTabProductTableViewCell {
    func configureSubviews() {
        let contentStackView = createContentStackView()
        let stackView = UIStackView(arrangedSubviews: [productImageView, contentStackView])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .leading

        stackView.translatesAutoresizingMaskIntoConstraints = false
        bottomBorderView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        contentView.addSubview(bottomBorderView)
        contentView.pinSubviewToAllEdges(stackView, insets: UIEdgeInsets(top: Constants.stackViewInset,
                                                                         left: Constants.stackViewInset,
                                                                         bottom: Constants.stackViewInset,
                                                                         right: Constants.stackViewInset))

        // Not initially enabled, saved for possible compact icon case
        productImageViewFixedHeightConstraint = productImageView.heightAnchor.constraint(equalTo: stackView.heightAnchor)

        // Assigning a minimum default height to the labels might be helpful (e.g for the ghosting placeholder animation)
        nameLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.nameLabelDefaultMinimumHeight).isActive = true
        detailsLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.detailsLabelDefaultMinimumHeight).isActive = true

        NSLayoutConstraint.activate([
            bottomBorderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorderView.leadingAnchor.constraint(equalTo: contentStackView.leadingAnchor),
            bottomBorderView.heightAnchor.constraint(equalToConstant: 1.0 / UIScreen.main.scale)
        ])
    }

    func createContentStackView() -> UIView {
        let contentStackView = UIStackView(arrangedSubviews: [nameLabel, detailsLabel])
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 4
        return contentStackView
    }

    func configureBackground() {
        configureDefaultBackgroundConfiguration()

        // Prevents overflow of selectedBackgroundView above dividers from adjacent cells
        clipsToBounds = true
    }

    func configureNameLabel() {
        nameLabel.applyBodyStyle()
        nameLabel.numberOfLines = 0
    }

    func configureDetailsLabel() {
        detailsLabel.numberOfLines = 0
    }

    func configureProductImageView() {

        productImageView.backgroundColor = Colors.imageBackgroundColor
        productImageView.tintColor = Colors.imagePlaceholderTintColor
        productImageView.layer.cornerRadius = Constants.cornerRadius
        productImageView.layer.borderWidth = Constants.borderWidth
        productImageView.layer.borderColor = Colors.imageBorderColor.cgColor
        productImageView.clipsToBounds = true

        // This multiplier matches the required size(37.5pt) for a 375pt(as per designs) content view width
        let widthConstraint = productImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.1)
        productImageViewRelationalWidthConstraint = widthConstraint

        NSLayoutConstraint.activate([
            widthConstraint,
            productImageView.widthAnchor.constraint(equalTo: productImageView.heightAnchor)
        ])
    }

    func configureProductImageViewForBigImages() {
        productImageViewRelationalWidthConstraint?.isActive = true
        productImageViewFixedHeightConstraint?.isActive = false
    }

    func configureProductImageViewForSmallIcons() {
        productImageViewRelationalWidthConstraint?.isActive = false
        productImageViewFixedHeightConstraint?.isActive = true
    }

    func configureBottomBorderView() {
        bottomBorderView.backgroundColor = .systemColor(.separator)
    }

    func configureSelectedProductImageOverlayView() {
        guard selectedProductImageOverlayView == nil else {
            return
        }

        let view = UIView(frame: .zero)
        view.backgroundColor = .primary
        view.translatesAutoresizingMaskIntoConstraints = false
        let checkmarkImage = UIImage.checkmarkInCellImageOverlay
        let checkmarkImageView = UIImageView(image: checkmarkImage)
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(checkmarkImageView)
        view.pinSubviewAtCenter(checkmarkImageView)
        selectedProductImageOverlayView = view

        productImageView.addSubview(view)
        productImageView.pinSubviewToAllEdges(view)
    }
}

/// Constants
///
private extension ProductsTabProductTableViewCell {
    enum Constants {
        static let cornerRadius = CGFloat(2.0)
        static let borderWidth = CGFloat(0.5)
        static let stackViewInset = CGFloat(16)
        static let nameLabelDefaultMinimumHeight = CGFloat(20)
        static let detailsLabelDefaultMinimumHeight = CGFloat(16)
    }

    enum Colors {
        static let imageBorderColor = UIColor.border
        static let imagePlaceholderTintColor = UIColor.systemColor(.systemGray2)
        static let imageBackgroundColor = UIColor.listForeground(modal: false)
    }
}

