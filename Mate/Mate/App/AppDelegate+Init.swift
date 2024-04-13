//
//  AppDelegate+Init.swift
//  Mate
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import CocoaLumberjack
import FiableUI

// MARK: - Initialization Methods
extension AppDelegate {
    
    /// Sets up CocoaLumberjack logging.
    ///
    final func setupCocoaLumberjack() {
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        
        guard let logger = fileLogger as? DDFileLogger else {
            return
        }
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(logger)
        DDLogVerbose("👀 setupCocoaLumberjack...")
        
    }
    
    /// Sets up the current Log Level.
    ///
    final func setupLogLevel(_ level: DDLogLevel) {
//        CocoaLumberjack.log = level
        DDLogVerbose("👀 setupLogLevel to \(level)")
        
    }

    
    func getSQLitePath() -> String? {
#if DEBUG
        // Get the URL for the app's "Documents" directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let databaseURL = documentsDirectory.appendingPathComponent("Mate.sqlite")
            return databaseURL.path
        }
        return nil
#endif

    }
    
    /// Sets up all of the component(s) Appearance.
    ///
    func setupComponentsAppearance() {
        setupWooAppearance()
        setupFancyAlertAppearance()
        setupFancyButtonAppearance()
    }

    /// Sets up WooCommerce's UIAppearance.
    ///
    func setupWooAppearance() {
        UINavigationBar.applyWooAppearance()
        UILabel.applyWooAppearance()
        UISearchBar.applyWooAppearance()
        UITabBar.applyWooAppearance()

        // Take advantage of a bug in UIAlertController to style all UIAlertControllers with WC color
        window?.tintColor = .primary
    }

    /// Sets up FancyAlert's UIAppearance.
    ///
    func setupFancyAlertAppearance() {
        let appearance = FancyAlertView.appearance()
        appearance.bodyBackgroundColor = .systemColor(.systemBackground)
        appearance.bottomBackgroundColor = appearance.bodyBackgroundColor
        appearance.bottomDividerColor = .listSmallIcon
        appearance.topDividerColor = appearance.bodyBackgroundColor

        appearance.titleTextColor = .text
        appearance.titleFont = UIFont.title2SemiBold

        appearance.bodyTextColor = .text
        appearance.bodyFont = UIFont.body

        appearance.actionFont = UIFont.headline
        appearance.infoFont = UIFont.subheadline
        appearance.infoTintColor = .accent
        appearance.headerBackgroundColor = .alertHeaderImageBackgroundColor
    }

    /// Sets up FancyButton's UIAppearance.
    ///
    func setupFancyButtonAppearance() {
        let appearance = FancyButton.appearance()
        appearance.primaryNormalBackgroundColor = .primaryButtonBackground
        appearance.primaryNormalBorderColor = .primaryButtonBorder
        appearance.primaryHighlightBackgroundColor = .primaryButtonDownBackground
        appearance.primaryHighlightBorderColor = .primaryButtonDownBorder
    }
    
}


// MARK: - UITabBar + Woo
//
extension UITabBar {
    /// Applies the default WC's Appearance
    ///
    class func applyWooAppearance() {
        let appearance = Self.appearance()
        appearance.barTintColor = .appTabBar
        appearance.tintColor = .accent

        // tab bar needs to be translucent to get rid of the extra space at the bottom of
        // the view controllers embedded in split view.
        appearance.isTranslucent = true

        /// iOS 13.0 and 13.1 doesn't render the tabbar shadow color correctly while in dark mode.
        /// To fix it, we have to specifically set it in the `standardAppearance` object.
        ///
        appearance.standardAppearance = createWooTabBarAppearance()

        /// This is needed because the tab bar background has the wrong color under iOS 15 (using Xcode 13).
        /// More: issue-5018
        ///
        appearance.scrollEdgeAppearance = appearance.standardAppearance
    }

    /// Creates an appearance object for a tabbar with the default WC style.
    ///
    private static func createWooTabBarAppearance() -> UITabBarAppearance {
        let standardAppearance = UITabBarAppearance()
        standardAppearance.backgroundColor = .appTabBar
        standardAppearance.shadowColor = .systemColor(.separator)
        applyWooAppearance(to: standardAppearance.inlineLayoutAppearance)
        applyWooAppearance(to: standardAppearance.stackedLayoutAppearance)
        applyWooAppearance(to: standardAppearance.compactInlineLayoutAppearance)
        return standardAppearance
    }

    /// Configures the appearance object for a tabbar's items with the default WC style.
    ///
    private static func applyWooAppearance(to tabBarItemAppearance: UITabBarItemAppearance) {
        tabBarItemAppearance.normal.badgeTextAttributes = [.foregroundColor: UIColor.white]
        tabBarItemAppearance.selected.badgeTextAttributes = [.foregroundColor: UIColor.white]
        tabBarItemAppearance.disabled.badgeTextAttributes = [.foregroundColor: UIColor.white]
        tabBarItemAppearance.normal.badgeBackgroundColor = .primary
        tabBarItemAppearance.selected.badgeBackgroundColor = .primary
        tabBarItemAppearance.disabled.badgeBackgroundColor = .primary
    }
}
