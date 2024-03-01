//
//  WeatherDetailRouter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

protocol WeatherDetailRouterProtocol: AnyObject{
    func navigate(_ route: DetailRoutes)
}
enum DetailRoutes {
    case openURL(url: URL)
    case city(city: CityResult)
}

final class WeatherDetailRouter {
    weak var viewController: WeatherDetailViewController?
    
    static func createModule() -> WeatherDetailViewController{
        let view = WeatherDetailViewController()
        let interactor = DetailInteractor()
        let router = WeatherDetailRouter()
        let presenter = DetailPresenter(view: view, router: router, interactor: interactor)
        view.presenter = presenter
        interactor.output = presenter
        router.viewController = view
        return view
    }
}

extension WeatherDetailRouter: WeatherDetailRouterProtocol {
    func navigate(_ route: DetailRoutes) {
        
        switch route {
        case .openURL(let url):
            print(url)
        case .city(city: let city):
            let detailVC = WeatherDetailRouter.createModule()
            detailVC.city = city
            viewController?.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}
