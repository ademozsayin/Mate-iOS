//
//  LoadingShowable.swift
//  Components
//
//  Created by Adem Özsayın on 26.02.2024.
//

import UIKit

/**
 A protocol for view controllers that can display loading indicators.

 Conforming view controllers can use this protocol to show and hide loading indicators using the `LoadingView` shared instance.

 - Important: Ensure that the `LoadingView` is properly configured before invoking the `showLoading()` method.
 */
protocol LoadingShowable where Self: UIViewController {
    /**
     Displays the loading indicator using the shared `LoadingView`.

     - Note: This method should be implemented by conforming view controllers to display the loading indicator.
     */
    func showLoading()

    /**
     Hides the loading indicator using the shared `LoadingView`.

     - Note: This method should be implemented by conforming view controllers to hide the loading indicator.
     */
    func hideLoading()
}

extension LoadingShowable {
    /**
     Default implementation to show the loading indicator using the shared `LoadingView`.

     - Note: This method uses the shared `LoadingView` to start the loading animation.
     */
    func showLoading() {
        LoadingView.shared.startLoading()
    }

    /**
     Default implementation to hide the loading indicator using the shared `LoadingView`.

     - Note: This method uses the shared `LoadingView` to stop the loading animation and hide the loading view.
     */
    func hideLoading() {
        LoadingView.shared.hideLoading()
    }
}
