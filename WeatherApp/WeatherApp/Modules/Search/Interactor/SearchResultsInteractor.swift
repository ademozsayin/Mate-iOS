//
//  SearchResultsInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

/// Protocol defining the interactions handled by the SearchResultsInteractor.
protocol SearchResultsInteractorProtocol: AnyObject {
    /// Fetches weather information for a given query.
    ///
    /// - Parameter query: The search query.
    func fetchWeather(query: String)
}

/// Protocol defining the output interactions handled by the SearchResultsInteractor.
protocol SearchResultsInteractorOutputProtocol: AnyObject {
    /// Outputs the result of fetching city information.
    ///
    /// - Parameter result: The search result.
    func fetchCityOutput(result: SearchResult)
}

/// Class responsible for fetching weather information for search results.
final class SearchResultsInteractor {
    /// The output delegate for handling fetched results.
    var output: SearchResultsInteractorOutputProtocol?
    /// The service responsible for fetching weather data.
    var service: WeatherProtocol
    
    /// Initializes the interactor with required dependencies.
    ///
    /// - Parameters:
    ///   - service: The weather service.
    ///   - output: The output delegate.
    init(
        service: WeatherProtocol = WeatherAPI(),
        output: SearchResultsInteractorOutputProtocol? = nil
    ) {
        self.output = output
        self.service = service
    }
}

extension SearchResultsInteractor: SearchResultsInteractorProtocol {
    /// Fetches weather information for a given query.
    ///
    /// - Parameter query: The search query.
    final func fetchWeather(query: String) {
        service.getWeatherBy(cityName: query) {  [weak self] result in
            guard let self else { return }
            self.output?.fetchCityOutput(result: result)
        }
    }
}
