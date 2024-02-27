//
//  DashboardInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking
import LocationService
import CoreLocation

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
    func fetchWeatherOutput(result: WeatherResponse)
}

/// Class responsible for handling business logic related to the dashboard.
final class DashboardInteractor {
    /// Reference to the output delegate.
    var output: DashboardInteractorOutputProtocol?
    /// Instance of the weather API for fetching weather data.
    var weatherApi: WeatherProtocol
    
    weak var presenter: DashboardPresenterProtocol?

    /// Initializes the interactor with required dependencies.
    ///
    /// - Parameters:
    ///   - weatherApi: The weather API service.
    ///   - output: The output delegate for the interactor.
    init(
        weatherApi: WeatherProtocol = WeatherAPI(),
        output: DashboardInteractorOutputProtocol? = nil,
        presenter: DashboardPresenterProtocol? = nil
    ) {
        self.weatherApi = weatherApi
        self.output = output
        self.presenter = presenter
    }
}

// Extension for additional protocol conformance
extension DashboardInteractor: DashboardInteractorProtocol {
    func fetchWeatherForUserLocation() {
        // Use location service to get user location
        LocationService.shared.delegate = self
        LocationService.shared.requestLocation()
        
    }
    
    /// Fetches the current weather data.
    func fetchCurrentWeather() {
        DDLogInfo(#function)
    }
}

extension DashboardInteractor: LocationServiceDelegate {
    func didFetchUserLocation(_ location: CLLocation) {
        WeatherAPI().getCurrentWeather(request: CLLocation.asWeatherRequest(location)) { result in
            switch result {
            case .success(let weatherInfo):
                print(weatherInfo)
//                self.presenter?.presentWeatherInfo(weatherInfo)
                self.output?.fetchWeatherOutput(result: weatherInfo)
            case .failure(let error):
                // Handle error
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    func didFailToFetchUserLocation(withError error: Error) {
        // Handle location fetch error
        DDLogError("Failed to fetch location: \(error)")
    }
    
}
