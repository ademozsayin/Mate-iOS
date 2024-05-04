//
//  LoadingView.swift
//  Mate
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation
import UIKit

/// Loading view to show a loader on top of a view
///
final class LoadingView: UIView {

    /// The main view that will containt all the elements, and that will be sized to match the size of the superview that will present the LoadingView
    ///
    private let mainView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// Main stack view to hold UI components vertically
    ///
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = Layout.stackViewSpacing
        return stackView
    }()

    /// Label to indicate the user to wait
    ///
    private let waitLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    /// Extra Large and purple loading indicator
    ///
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.transform = CGAffineTransform(scaleX: Layout.indicatorScaleFactor, y: Layout.indicatorScaleFactor)
        indicator.startAnimating()
        return indicator
    }()

    init(waitMessage: String, backgroundColor: UIColor? = .clear) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = backgroundColor
        addComponents()
        styleComponents()
        waitLabel.text = waitMessage
    }

    /// Adds and layouts components in the main view
    ///
    private func addComponents() {
        addSubview(mainView)
        mainView.addSubview(mainStackView)
        mainStackView.addArrangedSubviews([waitLabel, loadingIndicator])
        mainView.pinSubviewToAllEdges(mainStackView, insets: Layout.stackViewEdges)
        pinSubviewAtCenter(mainView)
    }

    /// Applies custom styles to components
    ///
    private func styleComponents() {
        mainView.backgroundColor = .listBackground
        mainView.layer.cornerRadius = Layout.cornerRadius
        waitLabel.applyHeadlineStyle()
        loadingIndicator.color = .primary
    }

    required init?(coder: NSCoder) {
        fatalError("Not supported")
    }
}

// MARK: Public Methods
extension LoadingView {
    func showLoader(in view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        alpha = 1.0
        isHidden = false
        view.addSubview(self)
        view.pinSubviewToAllEdges(self)
    }

    func hideLoader() {
        fadeOut { [weak self] _ in
            self?.removeFromSuperview()
        }
    }
}

// MARK: Constants
private extension LoadingView {
    enum Layout {
        static let stackViewEdges = UIEdgeInsets(top: 20, left: 20, bottom: 35, right: 20)
        static let stackViewSpacing = CGFloat(40)
        static let indicatorScaleFactor = CGFloat(2.5)
        static let cornerRadius = CGFloat(14.5)
    }
}

/// UIView animation helpers
///
private extension UIView {

    /// Unhides the current view by applying a fade-in animation.
    ///
    /// - Parameters:
    ///   - duration: The total duration of the animation, measured in seconds. (defaults to 0.5 seconds)
    ///   - delay: The amount of time (measured in seconds) to wait before beginning the animation.
    ///   - completion: The block executed when the animation sequence ends
    ///
    func fadeIn(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = nil) {
        self.alpha = 0.0

        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.isHidden = false
            self.alpha = 1.0
        }, completion: completion)
    }


    /// Hides the current view by applying a fade-out animation.
    ///
    /// - Parameters:
    ///   - duration: The total duration of the animations, measured in seconds. (defaults to 0.5 seconds)
    ///   - delay: The amount of time (measured in seconds) to wait before beginning the animation.
    ///   - completion: The block executed when the animation sequence ends
    ///
    func fadeOut(duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, completion: ((Bool) -> Void)? = nil) {
        self.alpha = 1.0

        UIView.animate(withDuration: duration, delay: delay, options: .curveEaseIn, animations: {
            self.alpha = 0.0
        }) { finished in
            self.isHidden = true
            completion?(finished)
        }
    }
}