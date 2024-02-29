//
//  Extensions+UIView.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 28.02.2024.
//

import Foundation
import UIKit

extension UIView {
    // available from iOS 11.0
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        self.layer.cornerRadius = radius
        var cornerMask = CACornerMask()
        if corners.contains(.topLeft) { cornerMask.insert(.layerMinXMinYCorner) }
        if corners.contains(.topRight) { cornerMask.insert(.layerMaxXMinYCorner) }
        if corners.contains(.bottomLeft) { cornerMask.insert(.layerMinXMaxYCorner) }
        if corners.contains(.bottomRight) { cornerMask.insert(.layerMaxXMaxYCorner) }
        self.layer.maskedCorners = cornerMask
    }
    
//    func setGradientBackground(colors: [UIColor]) {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = colors.map { $0.cgColor }
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
//        layer.insertSublayer(gradientLayer, at: 0)
//    }
    
    
}


extension UIView {
func applyGradient(colours: [UIColor]) -> Void {
 let gradient: CAGradientLayer = CAGradientLayer()
 gradient.frame = self.bounds
 gradient.colors = colours.map { $0.cgColor }
 gradient.startPoint = CGPoint(x : 0.0, y : 0.5)
 gradient.endPoint = CGPoint(x :1.0, y: 0.5)
 self.layer.insertSublayer(gradient, at: 0)
 }
}
