//
//  Extensions+UIView.swift
//  Mate
//
//  Created by Adem Özsayın on 28.02.2024.
//

import Foundation
import UIKit

/// An extension to `UIView` providing additional functionality.
extension UIView {
    /// Rounds the specified corners of the view with the given radius.
    ///
    /// - Parameters:
    ///   - corners: The corners to round.
    ///   - radius: The radius of the rounded corners.
    /// - Note: This method is available from iOS 11.0 and later.
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        self.layer.cornerRadius = radius
        var cornerMask = CACornerMask()
        if corners.contains(.topLeft) { cornerMask.insert(.layerMinXMinYCorner) }
        if corners.contains(.topRight) { cornerMask.insert(.layerMaxXMinYCorner) }
        if corners.contains(.bottomLeft) { cornerMask.insert(.layerMinXMaxYCorner) }
        if corners.contains(.bottomRight) { cornerMask.insert(.layerMaxXMaxYCorner) }
        self.layer.maskedCorners = cornerMask
    }
    
    /// Applies a gradient with the specified colors to the view's background.
    ///
    /// - Parameter colours: An array of colors to use in the gradient.
    func applyGradient(colours: [UIColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
}

// MARK: - UIView Helpers
//
extension UIView {

    @objc public func pinSubviewAtCenter(_ subview: UIView) {
        let newConstraints = [
            NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: subview, attribute: .centerX, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: subview, attribute: .centerY, multiplier: 1, constant: 0)
        ]

        addConstraints(newConstraints)
    }

    /// Adds constraints that pin a subview to self with zero insets.
    ///
    /// - Parameter subview: a subview to be pinned to self.
    @objc public func pinSubviewToAllEdges(_ subview: UIView) {
        pinSubviewToAllEdges(subview, insets: .zero)
    }

    /// Adds constraints that pin a subview to self with padding insets.
    ///
    /// - Parameters:
    ///   - subview: a subview to be pinned to self.
    ///   - insets: spacing between each subview edge to self. A positive value for an edge indicates that the subview is inside self on that edge.
    @objc public func pinSubviewToAllEdges(_ subview: UIView, insets: UIEdgeInsets) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: -insets.left),
            trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right),
            topAnchor.constraint(equalTo: subview.topAnchor, constant: -insets.top),
            bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom),
            ])
    }

    @objc public func pinSubviewToAllEdgeMargins(_ subview: UIView) {
        NSLayoutConstraint.activate([
            layoutMarginsGuide.leadingAnchor.constraint(equalTo: subview.leadingAnchor),
            layoutMarginsGuide.trailingAnchor.constraint(equalTo: subview.trailingAnchor),
            layoutMarginsGuide.topAnchor.constraint(equalTo: subview.topAnchor),
            layoutMarginsGuide.bottomAnchor.constraint(equalTo: subview.bottomAnchor),
            ])
    }

    /// Adds constraints that pin a subview to self's safe area with padding insets.
    ///
    /// - Parameters:
    ///   - subview: a subview to be pinned to self's safe area.
    @objc public func pinSubviewToSafeArea(_ subview: UIView) {
        pinSubviewToSafeArea(subview, insets: .zero)
    }

    /// Adds constraints that pin a subview to self's safe area with padding insets.
    ///
    /// - Parameters:
    ///   - subview: a subview to be pinned to self's safe area.
    ///   - insets: spacing between each subview edge to self's safe area. A positive value for an edge indicates that the subview is inside safe area on that edge.
    @objc public func pinSubviewToSafeArea(_ subview: UIView, insets: UIEdgeInsets) {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: subview.leadingAnchor, constant: -insets.left),
                safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: subview.trailingAnchor, constant: insets.right),
                safeAreaLayoutGuide.topAnchor.constraint(equalTo: subview.topAnchor, constant: -insets.top),
                safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: subview.bottomAnchor, constant: insets.bottom),
                ])
        }
    }

    @objc public func findFirstResponder() -> UIView? {
        if isFirstResponder {
            return self
        }

        for subview in subviews {
            guard let responder = subview.findFirstResponder() else {
                continue
            }

            return responder
        }

        return nil
    }

    @objc public func userInterfaceLayoutDirection() -> UIUserInterfaceLayoutDirection {
        return UIView.userInterfaceLayoutDirection(for: semanticContentAttribute)
    }

    public func changeLayoutMargins(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        let top = top ?? layoutMargins.top
        let left = left ?? layoutMargins.left
        let bottom = bottom ?? layoutMargins.bottom
        let right = right ?? layoutMargins.right

        layoutMargins = UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }
}

extension UIView {
    var safeLeadingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        get {
            safeAreaLayoutGuide.leadingAnchor
        }
    }
    var safeTrailingAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        get {
            safeAreaLayoutGuide.trailingAnchor
        }
    }
    var safeLeftAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        get {
            safeAreaLayoutGuide.leftAnchor
        }
    }
    var safeRightAnchor: NSLayoutAnchor<NSLayoutXAxisAnchor> {
        get {
            safeAreaLayoutGuide.rightAnchor
        }
    }
    var safeTopAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor> {
        get {
            safeAreaLayoutGuide.topAnchor
        }
    }
    var safeBottomAnchor: NSLayoutAnchor<NSLayoutYAxisAnchor> {
        get {
            safeAreaLayoutGuide.bottomAnchor
        }
    }
}
