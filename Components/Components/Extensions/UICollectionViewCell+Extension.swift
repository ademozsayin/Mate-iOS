//
//  UICollectionViewCell+Extension.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit.UICollectionViewCell

/// An extension to `UICollectionViewCell` providing default implementations for identifier and nib properties.
extension UICollectionViewCell {
    /// A string identifying the cell type.
    public static var identifier: String {
        return String(describing: self)
    }
    
    /// A nib object that represents the cell type.
    public static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
}
