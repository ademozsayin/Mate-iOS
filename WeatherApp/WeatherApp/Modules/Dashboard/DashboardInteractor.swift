//
//  DashboardInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking

final class DashboardInteractor{
    
    var weatherApi:WeatherProtocol

    init(weatherApi: WeatherProtocol) {
        self.weatherApi = weatherApi
    }
}
