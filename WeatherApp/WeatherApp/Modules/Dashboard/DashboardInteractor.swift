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
import CoreData
import UIKit

public typealias UserLocationResult = UserLocation

// MARK: - DashboardInteractorProtocol
protocol DashboardInteractorProtocol: AnyObject {
    /// Fetches the current weather data.
    func fetchCurrentWeather()
    func fetchWeatherForUserLocation()
    /// Fetches the last saved user location.
    func fetchLastSavedLocation() -> UserLocationResult?
    func fetchDailyWeatherData(_ location: CLLocation)
}

// MARK: - DashboardInteractorOutputProtocol
/// Protocol defining the output interactions of the DashboardInteractor.
protocol DashboardInteractorOutputProtocol: AnyObject {
    /// Outputs the result of weather data retrieval.
    ///
    /// - Parameter result: The retrieved weather data.
    func fetchWeatherOutput(result: WeatherResponse)
    
    func didFailToFetchUserLocation(withError error: Error) 
    
    func fetchDailyOutput(result: [List]) 
    
    func didFailedWith(message:String)
}

/// Class responsible for handling business logic related to the dashboard.
 
// MARK: - DashboardInteractor
final class DashboardInteractor {
    /// Reference to the output delegate.
    var output: DashboardInteractorOutputProtocol?
    /// Instance of the weather API for fetching weather data.
    var weatherApi: WeatherProtocol
    
    weak var presenter: DashboardPresenterProtocol?

    var locationDataManager: LocationDataManager


    /// Initializes the interactor with required dependencies.
    ///
    /// - Parameters:
    ///   - weatherApi: The weather API service.
    ///   - output: The output delegate for the interactor.
    init(
        weatherApi: WeatherProtocol = WeatherAPI(),
        output: DashboardInteractorOutputProtocol? = nil,
        presenter: DashboardPresenterProtocol? = nil,
        locationDataManager: LocationDataManager = CoreLocationDataManager()
    ) {
        self.weatherApi = weatherApi
        self.output = output
        self.presenter = presenter
        self.locationDataManager = locationDataManager
    }
    
    // Retrieve the last saved user location from Core Data
    final func fetchLastSavedLocation() -> UserLocationResult? {
        return locationDataManager.fetchLastLocation()
    }
}

// MARK: - DashboardInteractorProtocol
extension DashboardInteractor: DashboardInteractorProtocol {
    func fetchDailyWeatherData(_ location: CLLocation) {
        let request = CLLocation.asWeatherRequest(location)
        
        WeatherAPI().getDailyWeather(request: request) { [weak self]  result in
            guard let self else { return }
            switch result {
            case .success(let weatherInfo):
                self.output?.fetchDailyOutput(result: weatherInfo.list ?? [])
            case .failure(let error):
                print(error.localizedDescription)
                print("Error fetching weather: \(error)")
                self.output?.didFailedWith(message: error.message ?? "")
            }
        }
    }
    
    final func fetchWeatherForUserLocation() {
        // Use location service to get user location
        LocationService.shared.delegate = self
        LocationService.shared.requestLocation()
        
    }
    
    /// Fetches the current weather data.
    func fetchCurrentWeather() {
        DDLogInfo(#function)
    }
}

// MARK: - LocationServiceDelegate
extension DashboardInteractor: LocationServiceDelegate {
    final func didFetchUserLocation(_ location: CLLocation) {
        getCurrentWeather(location)
        fetchDailyWeatherData(location)
    }
    
    final func getCurrentWeather(_ location: CLLocation) {
        WeatherAPI().getCurrentWeather(request: CLLocation.asWeatherRequest(location)) {[weak self]  result in
            guard let self else { return }
            switch result {
            case .success(let weatherInfo):
                // Convert WeatherResponse to WeatherResponseCD
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    fatalError("AppDelegate not found")
                }
                let managedContext = appDelegate.persistentContainer.viewContext

                let weatherInfoCD = UserLocation(context: managedContext)
                weatherInfoCD.latitude = weatherInfo.coord?.lat ?? 0.0
                weatherInfoCD.longitude = weatherInfo.coord?.lon ?? 0.0
                weatherInfoCD.name = weatherInfo.name ?? ""
                let temperature:String? = "\(weatherInfo.main?.temp ?? 0.0)"
                weatherInfoCD.degree = temperature
                // Assuming datetime is a Date property in your Core Data model
                weatherInfoCD.date = Date() // Set datetime to current date
                // Save the converted WeatherResponseCD object
                locationDataManager.save(weatherInfoCD)
                
                self.output?.fetchWeatherOutput(result: weatherInfo)
                
            case .failure(let error):
                // Handle error
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    final func didFailToFetchUserLocation(withError error: Error) {
        // Handle location fetch error
        DDLogError("Failed to fetch location: \(error)")
        output?.didFailToFetchUserLocation(withError: error)
    }
}
