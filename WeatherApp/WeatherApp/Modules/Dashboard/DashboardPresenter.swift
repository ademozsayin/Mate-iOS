//
//  DashboardPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Networking
import CoreLocation

/// Protocol defining the interactions handled by the DashboardPresenter.
protocol DashboardPresenterProtocol: AnyObject {
    /// Called when the view is loaded and ready.
    func viewDidLoad()
    /// Presents weather information.
    ///
    /// - Parameter weatherInfo: The weather information to present.
    func presentWeatherInfo(_ weatherInfo: WeatherResponse)
    
    func displayLastSavedLocation(completion: @escaping (UserLocation?) -> Void)
}

/// Class responsible for presenting data to the dashboard view.
final class DashboardPresenter: DashboardPresenterProtocol {
    
    /// Reference to the dashboard view.
    unowned var view: DashboardViewControllerProtocol?
    /// Reference to the router handling navigation.
    let router: DashboardRouterProtocol?
    /// Reference to the interactor handling data retrieval.
    let interactor: DashboardInteractorProtocol?
    
    /// Initializes the presenter with required dependencies.
    ///
    /// - Parameters:
    ///   - view: The dashboard view.
    ///   - router: The router for navigation.
    ///   - interactor: The interactor for data retrieval.
    init(
        view: DashboardViewControllerProtocol,
        router: DashboardRouterProtocol,
        interactor: DashboardInteractorProtocol
    ){
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    // Display last saved location
    func displayLastSavedLocation(completion: @escaping (UserLocation?) -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            if let lastLocation = self.interactor?.fetchLastSavedLocation() {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    // Display last saved location in your UI
                    // For example:
                    print("Last saved location: \(lastLocation)")
                    // Update UI with last saved location
                    // Example: view?.updateLocationLabel(lastLocation)
                    self.view?.showLastUpdatedWeather(info: lastLocation)
                    
                    // Call completion handler with the fetched location
                    completion(lastLocation)
                }
            } else {
                // Call completion handler with nil if no location is found
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }

        
    /// Called when the view is loaded and ready.
    func viewDidLoad() {
        view?.showLoading()
        // Display last saved location when view loads
        displayLastSavedLocation { [weak self] location in
            guard let self else { return }
            self.interactor?.fetchWeatherForUserLocation()
        }
    }
}

// Extension for additional protocol conformance
extension DashboardPresenter: DashboardInteractorOutputProtocol {
    func fetchWeatherOutput(result: WeatherResponse) {
        view?.displayWeatherInfo(result)
        view?.hideLoading()
    }
    
    /// Outputs the result of weather data retrieval.
    ///
    /// - Parameter result: The retrieved weather data.
    func fetchWeatherOutput(result: Networking.CurrentWeather) {
        DDLogInfo(#function)
    }
    
    func presentWeatherInfo(_ weatherInfo: WeatherResponse) {
        view?.displayWeatherInfo(weatherInfo)
    }
}
