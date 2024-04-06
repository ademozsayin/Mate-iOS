//
//  Coordinator.swift
//  Mate
//
//  Created by Adem Özsayın on 22.03.2024.
//

import Foundation
import UIKit

/// A basic coordinator design pattern to help decouple things.
/// See: http://khanlou.com/2015/01/the-coordinator/
///
protocol Coordinator {
    var navigationController: UINavigationController { get }

    func start()
}
