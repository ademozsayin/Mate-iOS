//
//  File.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation
import UIKit

/// An extension to `UICollectionView` providing convenience methods for registering and dequeuing cells.
public extension UICollectionView {
    /// Registers a cell type for use in creating new collection view cells.
    ///
    /// - Parameter cellType: The type of cell to register.
    func register(cellType: UICollectionViewCell.Type) {
        register(cellType.nib, forCellWithReuseIdentifier: cellType.identifier)
    }
    
    /// Dequeues a reusable collection view cell of the specified type.
    ///
    /// - Parameters:
    ///   - cellType: The type of cell to dequeue.
    ///   - indexPath: The index path specifying the location of the cell.
    /// - Returns: A dequeued cell of the specified type.
    func dequeCell<T: UICollectionViewCell>(cellType: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue cell with identifier: \(cellType.identifier)")
        }
        return cell
    }
}
