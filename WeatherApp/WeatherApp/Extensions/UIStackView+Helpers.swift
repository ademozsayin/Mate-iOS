//
//  UIStackView+Helpers.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 18.03.2024.
//

import UIKit


extension UIStackView {
    /// Removes all the arranged subviews in the stack view.
    ///
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach(removeArrangedSubview(_:))
    }

    /// Adds an array of arranged subviews to the stack view.
    ///
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach({ addArrangedSubview($0) })
    }

    /// Removes all subviews from the stack view.
    ///
    func removeAllSubviews() {
        subviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
}
