//
//  DashboardPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking

protocol DashboardPresenterProtocol: AnyObject {
    func viewDidLoad()
}

final class DashboardPresenter: DashboardPresenterProtocol {

    unowned var view: DashboardViewControllerProtocol?
    let router: DashboardRouterProtocol?
    let interactor: DashboardInteractorProtocol?
    
    init(
        view: DashboardViewControllerProtocol,
        router: DashboardRouterProtocol,
        interactor: DashboardInteractorProtocol
    ){
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        view?.setTitle("Weather")
    }
}

extension DashboardPresenter: DashboardInteractorOutputProtocol {
    func fetchWeatherOutput(result: Networking.CurrentWeather) {
        DDLogInfo(#function)
    }
}
