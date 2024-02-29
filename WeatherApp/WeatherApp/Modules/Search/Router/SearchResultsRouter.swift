//
//  SearchResultsRouter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation

protocol SearchResultsRouterProtocol: AnyObject {
    func navigate(_ route: SearchRoutes)
}

enum SearchRoutes {
    case detail
}

final class SearchResultsRouter{
    weak var viewController: SearchResultsController?
    
    static func createModule() -> SearchResultsController{
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

extension SearchResultsRouter: SearchResultsRouterProtocol{
    func navigate(_ route: SearchRoutes) {
    }
}
