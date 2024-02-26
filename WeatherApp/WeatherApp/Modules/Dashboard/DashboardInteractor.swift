//
//  DashboardInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking

/// Protocol defining the interactions handled by the DashboardInteractor.
protocol DashboardInteractorProtocol: AnyObject {
    /// Fetches the current weather data.
    func fetchCurrentWeather()
    func fetchWeatherForUserLocation()

}

/// Protocol defining the output interactions of the DashboardInteractor.
protocol DashboardInteractorOutputProtocol: AnyObject {
    /// Outputs the result of weather data retrieval.
    ///
    /// - Parameter result: The retrieved weather data.
    func fetchWeatherOutput(result: CurrentWeather)
}

/// Class responsible for handling business logic related to the dashboard.
final class DashboardInteractor {
    /// Reference to the output delegate.
    var output: DashboardInteractorOutputProtocol?
    /// Instance of the weather API for fetching weather data.
    private var weatherApi: WeatherProtocol

    /// Initializes the interactor with required dependencies.
    ///
    /// - Parameters:
    ///   - weatherApi: The weather API service.
    ///   - output: The output delegate for the interactor.
    init(
        weatherApi: WeatherProtocol = WeatherAPI(),
        output: DashboardInteractorOutputProtocol? = nil
    ) {
        self.weatherApi = weatherApi
        self.output = output
    }
}

// Extension for additional protocol conformance
extension DashboardInteractor: DashboardInteractorProtocol {
    /// Fetches the current weather data.
    func fetchCurrentWeather() {
        DDLogInfo(#function)
    }
}
