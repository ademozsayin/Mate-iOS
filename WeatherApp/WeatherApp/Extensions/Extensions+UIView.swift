//
//  Extensions+UIView.swift
//  WeatherApp
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
