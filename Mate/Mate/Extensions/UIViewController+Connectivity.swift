//
//  UIViewController+Connectivity.swift
//  Mate
//
//  Created by Adem Özsayın on 22.03.2024.
//

import UIKit
import Combine

extension UIViewController {
    /// Defines if the view controller should show a "no connection" banner when offline.
    /// This requires the view controller to be contained inside a `OnsaNavigationController`.
    /// Defaults to `false`.
    ///
    @objc var shouldShowOfflineBanner: Bool {
        false
    }
}
