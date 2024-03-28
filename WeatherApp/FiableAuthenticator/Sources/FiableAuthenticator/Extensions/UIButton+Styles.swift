import UIKit
import FiableShared

extension UIButton {
    /// Applies the style that looks like a plain text link.
    func applyLinkButtonStyle() {
        backgroundColor = .clear
        titleLabel?.font = WPStyleGuide.fontForTextStyle(.body)
        titleLabel?.textAlignment = .natural

        let buttonTitleColor = FiableAuthenticator.shared.unifiedStyle?.textButtonColor ?? FiableAuthenticator.shared.style.textButtonColor
        let buttonHighlightColor = FiableAuthenticator.shared.unifiedStyle?.textButtonHighlightColor ?? FiableAuthenticator.shared.style.textButtonHighlightColor
        setTitleColor(buttonTitleColor, for: .normal)
        setTitleColor(buttonHighlightColor, for: .highlighted)
    }
}
