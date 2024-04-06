//
//  MapViewController.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import SwiftUI
import UIKit
import FiableRedux

/// Displays a grid view of all available menu in the "Menu" tab (eg. View Store, Reviews, Coupons, etc...)
final class MapViewController: UIHostingController<MapView> {
    private let viewModel: MapViewModel

    init(navigationController: UINavigationController?) {
        self.viewModel = MapViewModel(navigationController: navigationController)
        super.init(rootView: MapView(viewModel: viewModel))
        configureTabBarItem()
        
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        view.backgroundColor = .yellow
        print(#file)
//        viewModel.viewDidAppear()
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // We want to hide navigation bar *only* on HubMenu screen. But on iOS 16, the `navigationBarHidden(true)`
        // modifier on `HubMenu` view hides the navigation bar for the whole navigation stack.
        // Here we manually hide or show navigation bar when entering or leaving the HubMenu screen.
        if #available(iOS 16.0, *) {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if #available(iOS 16.0, *) {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
}



private extension MapViewController {
    func configureTabBarItem() {
        tabBarItem.title = Localization.tabTitle
        tabBarItem.image = .hubMenu
        tabBarItem.accessibilityIdentifier = "tab-bar-menu-item"
    }
}

private extension MapViewController {
    enum Localization {
        static let tabTitle = NSLocalizedString("Map", comment: "Title of the Menu tab")
    }
}
