//
//  UICollectionViewCell+Extension.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit

/// An extension to `UICollectionViewCell` providing default implementations for identifier and nib properties.
public extension UICollectionViewCell {
    /// A string identifying the cell type.
    static var identifier: String {
        return String(describing: self)
    }
    
    /// A nib object that represents the cell type.
    static var nib: UINib {
        let bundle = Bundle(for: self)
        return UINib(nibName: identifier, bundle: bundle)
    }
}
