//
//  SearchResultsRouter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation

/// Protocol defining the routing actions for the SearchResultsViewController.
protocol SearchResultsRouterProtocol: AnyObject {
    /// Navigates to the specified route.
    ///
    /// - Parameter route: The route to navigate to.
    func navigate(_ route: SearchRoutes)
}

/// Enum defining the possible routes for navigation from the search results view.
enum SearchRoutes {
    case detail
}

/// Class responsible for routing from the search results view.
final class SearchResultsRouter {
    /// Weak reference to the search results view controller.
    weak var viewController: SearchResultsController?
    
    /// Creates and configures the search results module.
    ///
    /// - Returns: The configured search results view controller.
    static func createModule() -> SearchResultsController {
        let view = SearchResultsController()
        let interactor = SearchResultsInteractor()
        let router = SearchResultsRouter()
        let presenter = SearchResultsPresenter(view: view, router: router, interactor: interactor)
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        return view
    }
}

extension SearchResultsRouter: SearchResultsRouterProtocol {
    /// Navigates to the specified route.
    ///
    /// - Parameter route: The route to navigate to.
    final func navigate(_ route: SearchRoutes) {
        // Implement navigation logic here based on the specified route
    }
}
