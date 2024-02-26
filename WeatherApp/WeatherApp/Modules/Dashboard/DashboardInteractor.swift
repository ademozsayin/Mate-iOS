//
//  DashboardInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking

protocol DashboardInteractorProtocol: AnyObject {
    func fetchCurrentWeather()
}

protocol DashboardInteractorOutputProtocol: AnyObject{
    func fetchWeatherOutput(result: CurrentWeather)
}

final class DashboardInteractor{
    
    var output: DashboardInteractorOutputProtocol?
    private var weatherApi:WeatherProtocol

    init(
        weatherApi: WeatherProtocol = WeatherAPI(),
        output: DashboardInteractorOutputProtocol? = nil
    ) {
        self.weatherApi = weatherApi
        self.output = output
    }
}

extension DashboardInteractor: DashboardInteractorProtocol {
    func fetchCurrentWeather() {
        DDLogInfo(#function)
    }
}
