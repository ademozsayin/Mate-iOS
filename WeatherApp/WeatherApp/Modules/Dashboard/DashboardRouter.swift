//
//  DashboardRouter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

protocol DashboardRouterProtocol: AnyObject{
//    func navigate(_ route: HomeRoutes)
}
enum DashboardRoutes {
//    case detail(movie: Movie)
}

final class DashboardRouter {
    weak var viewController: DashboardViewController?
    
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

extension DashboardRouter: DashboardRouterProtocol {
    func navigate(_ route: DashboardRoutes) {}
}
