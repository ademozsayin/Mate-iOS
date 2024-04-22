//
//  UIScrollView+Helpers.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import UIKit


extension UIScrollView {
    /// Configures a scroll view to be hidden and used to relay scroll action from any of the multiple scroll views in the view hierarchy below.
    func configureForLargeTitleWorkaround() {
        contentInsetAdjustmentBehavior = .never
        isHidden = true
        bounces = false
    }

    /// Updates the hidden scroll view from `scrollViewDidScroll` events from another `UIScrollView`.
    /// - Parameter scrollView: the scroll view where `scrollViewDidScroll` events are triggered.
    func updateFromScrollViewDidScrollEventForLargeTitleWorkaround(_ scrollView: UIScrollView) {
        contentSize = scrollView.contentSize
        contentOffset = scrollView.contentOffset
        panGestureRecognizer.state = scrollView.panGestureRecognizer.state
    }
}
