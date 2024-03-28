import UIKit

@objcMembers
public class WPStyleGuide: NSObject {
    
    static let maximumPointSize:CGFloat = 16
    // MARK: - Fonts and Text
    
    public static func subtitleFont() -> UIFont {
//        let maximumPointSize = maxFontSize()
        return font(forTextStyle: .caption1, maximumPointSize: WPStyleGuide.maximumPointSize)
    }
    
    public static func subtitleAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 14
        paragraphStyle.maximumLineHeight = 14
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: subtitleFont()]
    }
    
    public static func subtitleFontItalic() -> UIFont {
        return UIFont.italicSystemFont(ofSize: subtitleFont().pointSize)
    }
    
    public static func subtitleItalicAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 14
        paragraphStyle.maximumLineHeight = 14
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: subtitleFontItalic()]
    }
    
    public static func subtitleFontBold() -> UIFont {
        return UIFont.systemFont(ofSize: subtitleFont().pointSize, weight: .bold)
    }
    
    public static func subtitleAttributesBold() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 14
        paragraphStyle.maximumLineHeight = 14
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: subtitleFontBold()]
    }
    
    public static func labelFont() -> UIFont {
        return UIFont.systemFont(ofSize: labelFontNormal().pointSize, weight: .bold)
    }
    
    public static func labelFontNormal() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .caption2)
    }
    
    public static func labelAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 12
        paragraphStyle.maximumLineHeight = 12
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: labelFont()]
    }
    
    public static func regularTextFont() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .callout)
    }
    
    public static func regularTextFontSemiBold() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .headline)
    }
    
    public static func regularTextAttributes() -> [NSAttributedString.Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 24
        paragraphStyle.maximumLineHeight = 24
        return [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: regularTextFont()]
    }
    
    public static func tableviewTextFont() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .callout)
    }
    
    public static func tableviewSubtitleFont() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .callout)
    }
    
    public static func tableviewSectionHeaderFont() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    public static func tableviewSectionFooterFont() -> UIFont {
        return UIFont.preferredFont(forTextStyle: .footnote)
    }
    
    // MARK: - Colors
    
    public static func colorWith(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
    
    // MARK: - Blues
    
    public static func wordPressBlue() -> UIColor {
        return colorWith(red: 0, green: 135, blue: 190, alpha: 1.0)
    }
    
    public static func lightBlue() -> UIColor {
        return colorWith(red: 120, green: 220, blue: 250, alpha: 1.0)
    }
    
    public static func mediumBlue() -> UIColor {
        return colorWith(red: 0, green: 170, blue: 220, alpha: 1.0)
    }
    
    public static func darkBlue() -> UIColor {
        return colorWith(red: 0, green: 80, blue: 130, alpha: 1.0)
    }
    
    // MARK: - Greys
    
    public static func grey() -> UIColor {
        return colorWith(red: 135, green: 166, blue: 188, alpha: 1.0)
    }
    
    public static func lightGrey() -> UIColor {
        return colorWith(red: 243, green: 246, blue: 248, alpha: 1.0)
    }
    
    public static func greyLighten30() -> UIColor {
        return colorWith(red: 233, green: 239, blue: 243, alpha:1.0)
    }
    
    public static func greyLighten20() -> UIColor {
        return colorWith(red: 200, green: 215, blue: 225, alpha: 1.0)
    }

    public static func greyLighten10() -> UIColor {
        return colorWith(red: 168, green: 190, blue: 206, alpha: 1.0)
    }

    public static func greyDarken10() -> UIColor {
        return colorWith(red: 102, green: 142, blue: 170, alpha: 1.0)
    }

    public static func greyDarken20() -> UIColor {
        return colorWith(red: 79, green: 116, blue: 142, alpha: 1.0)
    }

    public static func greyDarken30() -> UIColor {
        return colorWith(red: 61, green: 89, blue: 109, alpha: 1.0)
    }

    public static func darkGrey() -> UIColor {
        return colorWith(red: 46, green: 68, blue: 83, alpha: 1.0)
    }

    // MARK: - Oranges

    public static func jazzyOrange() -> UIColor {
        return colorWith(red: 240, green: 130, blue: 30, alpha: 1.0)
    }

    public static func fireOrange() -> UIColor {
        return colorWith(red: 213, green: 78, blue: 33, alpha: 1.0)
    }

    // MARK: - Validations / Alerts

    public static func validGreen() -> UIColor {
        return colorWith(red: 74, green: 184, blue: 102, alpha: 1.0)
    }

    public static func warningYellow() -> UIColor {
        return colorWith(red: 240, green: 184, blue: 73, alpha: 1.0)
    }

    public static func errorRed() -> UIColor {
        return colorWith(red: 217, green: 79, blue: 79, alpha: 1.0)
    }

    public static func alertYellowDark() -> UIColor {
        return colorWith(red: 0xF0, green: 0xB8, blue: 0x49, alpha: 1.0)
    }

    public static func alertYellowLighter() -> UIColor {
        return colorWith(red: 0xFE, green: 0xF8, blue: 0xEE, alpha: 1.0)
    }

    public static func alertRedDarker() -> UIColor {
        return colorWith(red: 0x6D, green: 0x18, blue: 0x18, alpha: 1.0)
    }
    
    // MARK: - Misc Colors

    public static func keyboardColor() -> UIColor {
        // Pre iOS 7.1 uses a the lighter keyboard background.
        // There doesn't seem to be a good way to get the keyboard background color
        // programatically so we'll rely on checking the OS version.
        // Approach based on http://stackoverflow.com/a/5337804
        let versionStr = UIDevice.current.systemVersion
        let hasLighterKeyboard = versionStr.compare("7.1", options: .numeric) == .orderedAscending

        if hasLighterKeyboard {
            return UIColor(red: 220.0 / 255.0, green: 223.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        }

        return UIColor(red: 204.0 / 255.0, green: 208.0 / 255.0, blue: 214.0 / 255.0, alpha: 1.0)
    }

    public static func textFieldPlaceholderGrey() -> UIColor {
        return grey()
    }

    // TODO: Move to feature category
    public static func buttonActionColor() -> UIColor {
        return wordPressBlue()
    }

    // TODO: Move to feature category
    public  static func nuxFormText() -> UIColor {
        return darkGrey()
    }

    // TODO: Move to feature category
    public static func nuxFormPlaceholderText() -> UIColor {
        return grey()
    }


    // MARK: - Bar styles

    public  static func barButtonStyleForDone() -> UIBarButtonItem.Style {
        return .plain
    }

    public static func barButtonStyleForBordered() -> UIBarButtonItem.Style {
        return .plain
    }

    public static func setLeftBarButtonItemWithCorrectSpacing(barButtonItem: UIBarButtonItem, forNavigationItem navigationItem: UINavigationItem) {
        navigationItem.leftBarButtonItems = [spacerForNavigationBarButtonItems(), barButtonItem]
    }

    public static func setRightBarButtonItemWithCorrectSpacing(barButtonItem: UIBarButtonItem, forNavigationItem navigationItem: UINavigationItem) {
        navigationItem.rightBarButtonItems = [spacerForNavigationBarButtonItems(), barButtonItem]
    }

    public static func spacerForNavigationBarButtonItems() -> UIBarButtonItem {
        let spacerButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerButton.width = -16.0
        return spacerButton
    }

    public static func configureNavigationBarAppearance() {
        UINavigationBar.appearance().barTintColor = wordPressBlue()
        UINavigationBar.appearance().tintColor = UIColor.white

        UIBarButtonItem.appearance().tintColor = UIColor.white
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: WPFontManager.systemRegular(ofSize: 17.0), NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: WPFontManager.systemRegular(ofSize: 17.0), NSAttributedString.Key.foregroundColor: UIColor(white: 1.0, alpha: 0.25)], for: .disabled)
    }

    // The app's appearance settings override the doc picker color scheme.
    // This method sets the nav colors so the doc picker has the correct appearance.
    // The app colors can be restored with configureNavigationBarAppearance().
    public static func configureDocumentPickerNavBarAppearance() {
        UINavigationBar.appearance().barTintColor = UIColor.white
        UINavigationBar.appearance().tintColor = mediumBlue()
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: mediumBlue()], for: .normal)
    }
}


extension WPStyleGuide {
    public  static func font(forTextStyle textStyle: UIFont.TextStyle, maximumPointSize: CGFloat) -> UIFont {
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        let font = UIFont.systemFont(ofSize: maximumPointSize)
        return fontMetrics.scaledFont(for: font)
    }
}
