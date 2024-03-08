//
//  UITableView+Extension.swift
//  Components
//
//  Created by Adem Özsayın on 8.03.2024.
//

import Foundation
import UIKit

public extension UITableView {
    /// Registers a cell type for use in creating new table view cells.
    ///
    /// - Parameter cellType: The type of cell to register.
    func register(cellType: UITableViewCell.Type) {
        register(cellType.nib, forCellReuseIdentifier: cellType.identifier)
    }
    
    /// Dequeues a reusable table view cell of the specified type.
    ///
    /// - Parameters:
    ///   - cellType: The type of cell to dequeue.
    ///   - indexPath: The index path specifying the location of the cell.
    /// - Returns: A dequeued cell of the specified type.
    func dequeCell<T: UITableViewCell>(cellType: T.Type, indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: cellType.identifier, for: indexPath) as? T else {
            fatalError("Failed to dequeue cell with identifier: \(cellType.identifier)")
        }
        return cell
    }
}
