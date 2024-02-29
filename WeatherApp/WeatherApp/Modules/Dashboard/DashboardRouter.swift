//
//  DashboardRouter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

/// Protocol defining navigation actions for the DashboardRouter.
// MARK: - DashboardRouterProtocol
protocol DashboardRouterProtocol: AnyObject {
    /// Navigate to a specific route within the dashboard.
    ///
    /// - Parameter route: The destination route to navigate to.
    func navigate(_ route: DashboardRoutes)
}

/// Enum defining different routes within the dashboard.
enum DashboardRoutes {
    // Define your routes here if needed.
    case search
}


// MARK: - DashboardRouter
final class DashboardRouter {
    /// Weak reference to the dashboard view controller.
    weak var viewController: DashboardViewController?

    /// Creates and configures the dashboard module.
    ///
    /// - Returns: The configured instance of DashboardViewController.
    static func createModule() -> DashboardViewController {
        let view = DashboardViewController()
        let interactor = DashboardInteractor()
        let router = DashboardRouter()
        let presenter = DashboardPresenter(
            view: view,
            router: router,
            interactor: interactor
        )
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        return view
    }
}

// MARK: - DashboardRouterProtocol
extension DashboardRouter: DashboardRouterProtocol {
    /// Navigate to a specific route within the dashboard.
    ///
    /// - Parameter route: The destination route to navigate to.
    final func navigate(_ route: DashboardRoutes) {
        // Implementation of navigation logic can be added here.
        // Currently, it's empty as no navigation logic is provided.
        switch route {
        case .search:
            let detailVC = DetailRouter.createModule()
            detailVC.movie = movie
            viewController?.navigationController?.pushViewController(detailVC, animated: true)
        default:
            return
        }
    }
}
