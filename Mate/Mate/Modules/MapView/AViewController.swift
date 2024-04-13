//
//  AViewController.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import UIKit

class AViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemPink
        
        tabBarItem.title = "DAshboard"
        tabBarItem.image = .location
        tabBarItem.accessibilityIdentifier = "tab-bar-menu-item"
    }
    
}
