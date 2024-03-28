import UIKit
import FiableShared
/// TextLinkButtonTableViewCell: a plain button made to look like a text link.
///
class TextLinkButtonTableViewCell: UITableViewCell {

    /// Private properties
    ///
    @IBOutlet private weak var iconView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet private weak var borderWidth: NSLayoutConstraint!
    @IBAction private func textLinkButtonTapped(_ sender: UIButton) {
        actionHandler?()
    }

    /// Public properties
    ///
    public static let reuseIdentifier = "TextLinkButtonTableViewCell"

    public var actionHandler: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        button.titleLabel?.adjustsFontForContentSizeCategory = true
        styleBorder()
    }

    public func configureButton(text: String?,
                                icon: UIImage? = nil,
                                accessibilityTrait: UIAccessibilityTraits = .button,
                                showBorder: Bool = false,
                                accessibilityIdentifier: String? = nil) {
        button.setTitle(text, for: .normal)

        let buttonTitleColor = FiableAuthenticator.shared.unifiedStyle?.textButtonColor ?? FiableAuthenticator.shared.style.textButtonColor
        let buttonHighlightColor = FiableAuthenticator.shared.unifiedStyle?.textButtonHighlightColor ?? FiableAuthenticator.shared.style.textButtonHighlightColor
        button.setTitleColor(buttonTitleColor, for: .normal)
        button.setTitleColor(buttonHighlightColor, for: .highlighted)
        button.accessibilityTraits = accessibilityTrait
        button.accessibilityIdentifier = accessibilityIdentifier

        borderView.isHidden = !showBorder

        iconView.image = icon
        iconView.isHidden = icon == nil
        iconView.tintColor = buttonTitleColor
    }

    /// Toggle button enabled / disabled
    ///
    public func enableButton(_ isEnabled: Bool) {
        button.isEnabled = isEnabled
    }

}

// MARK: - Private methods
private extension TextLinkButtonTableViewCell {

    /// Style the bottom cell border, called borderView.
    ///
    func styleBorder() {
        let borderColor = FiableAuthenticator.shared.unifiedStyle?.borderColor ?? FiableAuthenticator.shared.style.primaryNormalBorderColor
        borderView.backgroundColor = borderColor
        borderWidth.constant = WPStyleGuide.hairlineBorderWidth
    }
}

// MARK: - Constants
extension TextLinkButtonTableViewCell {
    struct Constants {
        static let passkeysID = "Passkeys"
    }
}
