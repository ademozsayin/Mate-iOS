//
//  LoadingView.swift
//  Components
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import UIKit

/**
 A singleton class responsible for managing and displaying a loading indicator view.

 Use this class to display a loading indicator on the main window.

 - Note: This class is intended to be used for displaying loading indicators in applications.

 ### Example:

 ```swift
 LoadingView.shared.startLoading()
 */
final public class LoadingView {
    
    /// The activity indicator view.
    private var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    static let shared = LoadingView()
    
    /// The blur view used as a background for the activity indicator.
    private var blurView: UIVisualEffectView = UIVisualEffectView()

    /// Private initializer to prevent external instantiation.
    private init(){
        configure()
    }
}

// MARK: - Privates
private extension LoadingView {
    /// Configures the appearance and layout of the loading view.
    final func configure() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = UIWindow(frame: UIScreen.main.bounds).frame
        activityIndicator.center = blurView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .large
        blurView.contentView.addSubview(activityIndicator)
    }
}

/**
 Extension to `LoadingView` providing additional functionality.
 */
// MARK: - Publics
public extension LoadingView {
    final func startLoading() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let mainWindow = windowScene.windows.first {
            mainWindow.addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            activityIndicator.startAnimating()
        }
    }
    
    final func hideLoading(){
        blurView.removeFromSuperview()
        activityIndicator.stopAnimating()
    }
}
