//
//  UINavigation+Appearence.swift
//  Mate
//
//  Created by Adem Özsayın on 10.04.2024.
//

import Foundation
import UIKit


// MARK: - UINavigationBar + Woo
//
extension UINavigationBar {

    /// Applies the default WC's Appearance
    ///
    class func applyWooAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .listForeground(modal: false)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.text]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.text]

        UINavigationBar.appearance().tintColor = .accent // The color of bar button items in the navigation bar
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    /// Creates the default WC's Appearance
    ///
    class func wooAppearance() -> UINavigationBarAppearance {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .listForeground(modal: false)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.text]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.text]
        return appearance
    }

    
    /// Applies UIKit's Default Appearance
    ///
    class func applyDefaultAppearance() {
        let appearance = UINavigationBar.appearance()
        appearance.barTintColor = nil
        appearance.titleTextAttributes = nil
        appearance.isTranslucent = true
        appearance.tintColor = nil
    }
    
    func removeShadow() {
        let updatedSandardAppearance = self.standardAppearance
        updatedSandardAppearance.removeShadow()
        self.standardAppearance = updatedSandardAppearance

        let updatedCompactAppearance = self.compactAppearance ?? UINavigationBar.wooAppearance()
        updatedCompactAppearance.removeShadow()
        self.compactAppearance = updatedCompactAppearance

        let updatedScrollEdgeAppearance = self.scrollEdgeAppearance ?? UINavigationBar.wooAppearance()
        updatedScrollEdgeAppearance.removeShadow()
        self.scrollEdgeAppearance = updatedScrollEdgeAppearance
    }
}

extension UILabel {

    /// Applies the default WC's Appearance
    ///
    class func applyWooAppearance() {
        let appearanceInHeaderFooter = UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self])
        appearanceInHeaderFooter.textColor = .listIcon
    }
}

extension UINavigationBarAppearance {
    func removeShadow() {
        shadowImage = nil
        shadowColor = .none
    }
}


// MARK: - UISearchBar + Woo
//
extension UISearchBar {

    /// Applies the default WC's Appearance
    ///
    class func applyWooAppearance() {
        let appearance = UISearchBar.appearance()
        appearance.barTintColor = .basicBackground

        appearance.layer.borderColor = UIColor.listSmallIcon.cgColor
        appearance.layer.borderWidth = 1.0

        let brandColor = UIColor.primary
        appearance.tintColor = brandColor

        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: brandColor]
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(cancelButtonAttributes, for: .normal)

        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.textTertiary]
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = textAttributes
    }
}


// Setting the UITextField background color via the appearance proxy does not seem to work
// As a workaround, this property exposes the texfield, so the background color can be set manually
//
extension UISearchBar {
    var textField: UITextField? {
        return subviews.map { $0.subviews.first(where: { $0 is UITextInputTraits}) as? UITextField }
            .compactMap { $0 }
            .first
    }
}
