//
//  UITableViewCell+Extension.swift
//  Components
//
//  Created by Adem Özsayın on 8.03.2024.
//

import UIKit

/// An extension to `UICollectionViewCell` providing default implementations for identifier and nib properties.
public extension UITableViewCell {
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
