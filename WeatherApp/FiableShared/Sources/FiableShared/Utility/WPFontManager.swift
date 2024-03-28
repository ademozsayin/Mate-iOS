import UIKit
import Foundation
import CoreText

public class WPFontManager {
    public static let FontTypeTTF = "ttf"
    public static let FontTypeOTF = "otf"

    // MARK: - System Fonts

    public class func systemLight(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .light)
    }

    public class func systemItalic(ofSize size: CGFloat) -> UIFont {
        return UIFont.italicSystemFont(ofSize: size)
    }

    public class func systemBold(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    public class func systemSemiBold(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }

    public class func systemRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .regular)
    }

    public class func systemMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: .medium)
    }

    // MARK: - Noto Fonts

    public static let NotoBoldFontName = "Poppins-Bold"
    public static let NotoBoldFileName = "Poppins-Bold"
    public static let NotoBoldItalicFontName = "Poppins-BoldItalic"
    public static let NotoBoldItalicFileName = "Poppins-BoldItalic"
    public static let NotoItalicFontName = "Poppins-Italic"
    public static let NotoItalicFileName = "Poppins-Italic"
    public static let NotoRegularFontName = "Poppins"
    public static let NotoRegularFileName = "Poppins-Regular"

    public class func loadNotoFontFamily() {
        loadFont(named: NotoRegularFontName, resourceNamed: NotoRegularFileName, fontType: FontTypeTTF)
        loadFont(named: NotoBoldFileName, resourceNamed: NotoBoldFileName, fontType: FontTypeTTF)
        loadFont(named: NotoBoldItalicFontName, resourceNamed: NotoBoldItalicFileName, fontType: FontTypeTTF)
        loadFont(named: NotoItalicFontName, resourceNamed: NotoItalicFileName, fontType: FontTypeTTF)
    }

    public class func notoBold(ofSize size: CGFloat) -> UIFont {
        return font(named: NotoBoldFontName, resourceName: NotoBoldFileName, fontType: FontTypeTTF, size: size)
    }

    public class func notoBoldItalic(ofSize size: CGFloat) -> UIFont {
        return font(named: NotoBoldItalicFontName, resourceName: NotoBoldItalicFileName, fontType: FontTypeTTF, size: size)
    }

    public class func notoItalic(ofSize size: CGFloat) -> UIFont {
        return font(named: NotoItalicFontName, resourceName: NotoItalicFileName, fontType: FontTypeTTF, size: size)
    }

    public class func notoRegular(ofSize size: CGFloat) -> UIFont {
        return font(named: NotoRegularFontName, resourceName: NotoRegularFileName, fontType: FontTypeTTF, size: size)
    }

    // MARK: - Private Methods

    public class func font(named fontName: String, resourceName: String, fontType: String, size: CGFloat) -> UIFont {
        var font = UIFont(name: fontName, size: size)
        if font == nil {
            loadFontResourceNamed(resourceName, withExtension: FontTypeTTF)
            font = UIFont(name: fontName, size: size)

            // Safe fallback
            if font == nil {
                font = UIFont.systemFont(ofSize: size)
            }
        }
        return font!
    }

    public class func loadFont(named fontName: String, resourceNamed: String, fontType: String) {
        if let font = UIFont(name: fontName, size: UIFont.systemFontSize) {
            return
        }
        loadFontResourceNamed(resourceNamed, withExtension: FontTypeTTF)
    }

    public class func loadFontResourceNamed(_ name: String, withExtension extension: String) {
        guard let url = resourceBundle().url(forResource: name, withExtension: `extension`) else {
            return
        }

        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterFontsForURL(url as CFURL, CTFontManagerScope.process, &error) else {
            if let error = error?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(error)
                print("Failed to load font: \(errorDescription ?? "" as CFString)")
            }
            return
        }
    }

    public class func resourceBundle() -> Bundle {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        let defaultBundle = Bundle(for: self)
        let sharedBundleURL = defaultBundle.resourceURL?.appendingPathComponent("WordPressShared.bundle")
        if let sharedBundleURL = sharedBundleURL, let sharedBundle = Bundle(url: sharedBundleURL) {
            return sharedBundle
        }
        return defaultBundle
        #endif
    }
}
