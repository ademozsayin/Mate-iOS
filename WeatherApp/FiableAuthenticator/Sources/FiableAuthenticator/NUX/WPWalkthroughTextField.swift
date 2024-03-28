import UIKit
import Foundation
import FiableShared

@IBDesignable
open class WPWalkthroughTextField: UITextField {
    @IBInspectable var showTopLineSeparator: Bool = false
    @IBInspectable var showSecureTextEntryToggle: Bool = false
    @IBInspectable var leftViewImage: UIImage?
    @IBInspectable var secureTextEntryImageColor: UIColor? = .gray
    
    @IBInspectable var secureTextEntryToggle:UIButton?
    
    var leadingViewWidth: CGFloat = 30
    var trailingViewWidth: CGFloat = 40
    var textInsets: UIEdgeInsets = .zero
    var leadingViewInsets: UIEdgeInsets = .zero
    var trailingViewInsets: UIEdgeInsets = .zero
    var contentInsets: UIEdgeInsets = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    public init(leftViewImage: UIImage?) {
        self.leftViewImage = leftViewImage
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
        leadingViewWidth = 30
        trailingViewWidth = 40
        layer.cornerRadius = 0.0
        clipsToBounds = true
        showTopLineSeparator = false
        showSecureTextEntryToggle = false
        applyPlaceholderStyles()
        leadingViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    }
    
    private func applyPlaceholderStyles() {
        if let placeholder = placeholder {
            let attributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: WPStyleGuide.greyLighten10,
                .font: font ?? UIFont.systemFont(ofSize: 17)
            ]
            attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
        }
            }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawTopBorderIfNeeded(rect)
    }
    
    private func drawTopBorderIfNeeded(_ rect: CGRect) {
        guard showTopLineSeparator else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let path = UIBezierPath()
        let emptySpace = contentInsets.left
        
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight {
            path.move(to: CGPoint(x: rect.minX + emptySpace, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        } else {
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX - emptySpace, y: rect.minY))
        }
        
        path.lineWidth = UIScreen.main.scale / 2.0
        context.addPath(path.cgPath)
        context.setStrokeColor(UIColor(white: 0.87, alpha: 1.0).cgColor)
        context.strokePath()
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return textAreaRect(for: rect)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return textAreaRect(for: rect)
    }
    
    private func textAreaRect(for rect: CGRect) -> CGRect {
        var rect = rect
        rect.size.width -= textInsets.left + textInsets.right
        
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight {
            rect.origin.x += textInsets.left + leadingViewInsets.right
            rect.size.width -= leadingViewInsets.right + contentInsets.right
            if leftView == nil {
                rect.origin.x += contentInsets.left
                rect.size.width -= contentInsets.right
            }
        } else {
            rect.origin.x += textInsets.right + trailingViewInsets.left
            rect.size.width -= leadingViewInsets.right + trailingViewInsets.left
            
            if rightView == nil {
                rect.origin.x += contentInsets.right
                rect.size.width -= contentInsets.left
            }
            
            if leftView == nil {
                rect.size.width -= contentInsets.left
            }
        }
        
        return rect
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight {
            rect.origin.x += leadingViewInsets.left + contentInsets.left
        } else {
            rect.origin.x += trailingViewInsets.right + contentInsets.right
        }
        return rect
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        if UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .leftToRight {
            rect.origin.x -= trailingViewInsets.right + contentInsets.right
        } else {
            rect.origin.x -= leadingViewInsets.left + contentInsets.left
        }
        return rect
    }
    
    // MARK: - Secure Text Entry
    
    open override var isSecureTextEntry: Bool {
        didSet {
            font = nil
            font = .systemFont(ofSize: 17)
            updateSecureTextEntryToggleImage()
        }
    }
    
    private func updateSecureTextEntryToggleImage() {
        guard let secureTextEntryToggle else { return }
        let image = UIImage.add//isSecureTextEntry ? secureTextEntryImageHidden : secureTextEntryImageVisible
        secureTextEntryToggle.setImage(image, for: .normal)
        secureTextEntryToggle.sizeToFit()
        secureTextEntryToggle.tintColor = secureTextEntryImageColor
    }
}
