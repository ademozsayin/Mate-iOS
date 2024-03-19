import Foundation

extension Bundle {

    /// Returns the WordPressShared Bundle
    /// If installed via CocoaPods, this will be WordPressShared.bundle,
    /// otherwise it will be the framework bundle.
    ///
    @objc public class var fiableSharedBundle: Bundle {
        return Bundle.module
    }
}
