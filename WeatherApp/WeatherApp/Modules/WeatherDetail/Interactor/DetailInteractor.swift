//
//  DetailInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

/// Protocol for handling detail interactor actions.
protocol DetailInteractorProtocol: AnyObject {
    /// Fetches detail for a city.
    /// - Parameter city: The name of the city.
    func fetchDetail(city: String)
}

/// Protocol for receiving outputs from the detail interactor.
protocol DetailInteractorOutputProtocol: AnyObject {
    /// Handles the output of fetching city detail.
    /// - Parameter result: The result containing city detail.
    func fetchCityDetailOutput(result: CityResult)
}

/// Interactor responsible for fetching city detail.
final class DetailInteractor {
    var output: DetailInteractorOutputProtocol?
    var service: WeatherProtocol
    
    /// Initializes a new instance of `DetailInteractor`.
    /// - Parameters:
    ///   - service: The weather service.
    ///   - output: The output handler.
    init(
        service: WeatherProtocol = WeatherAPI(),
        output: DetailInteractorOutputProtocol? = nil
    ) {
        self.output = output
        self.service = service
    }
}

extension DetailInteractor: DetailInteractorProtocol {
    func fetchDetail(city: String) {
        // Implementation to fetch city detail goes here
    }
}
