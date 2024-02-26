//
//  SplashRouter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import UIKit

// MARK: - SplashRouterProtocol
protocol SplashRouterProtocol: AnyObject {
    func navigate(_ route: SplashRoutes)
}

// MARK: - SplashRoutes
enum SplashRoutes {
    case homeScreen
}

// MARK: - SplashRouter
/// Router responsible for creating and configuring the Splash module.
final class SplashRouter {
    
    /// Reference to the Splash view controller.
    weak var viewController: SplashViewController?
    
    /// Creates and configures the Splash module.
    ///
    /// - Returns: An instance of `SplashViewController` configured with the Splash module.
    static func createModule() -> SplashViewController {
        let view = SplashViewController()
        let interactor = SplashInteractor()
        let router = SplashRouter()
        let presenter = SplashPresenter(view: view, router: router, interactor: interactor)
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        return view
    }
}

// MARK: - SplashRouterProtocol
extension SplashRouter: SplashRouterProtocol {
    
    /// Navigates to the specified route.
    ///
    /// - Parameter route: The route to navigate to.
    func navigate(_ route: SplashRoutes) {
        switch route {
        case .homeScreen:
            guard let window = viewController?.view.window else { return }
        }
    }
}
