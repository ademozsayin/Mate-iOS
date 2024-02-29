//
//  WeatherAPI.swift
//  Network
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Alamofire


// MARK: - Typealias
public typealias CurrentWeather = Result<WeatherResponse, NSError>
public typealias HourlyForecast = Result<Forecast, NSError>
public typealias SearchResult = Result<CityResult, NSError>

// MARK: - WeatherProtocol
/// Protocol defining the interface for weather-related operations.
public protocol WeatherProtocol {
    
    /// Retrieves the current weather information.
    ///
    /// - Parameters:
    ///   - request: The weather request parameters.
    ///   - completionHandler: A closure to be executed when the request finishes.
    func getCurrentWeather(request: WeatherRequest, completionHandler: @escaping (CurrentWeather) -> Void)
    
    func getDailyWeather(request: WeatherRequest, completionHandler: @escaping (HourlyForecast) -> Void)
    
    func getWeatherBy(cityName: String, completionHandler: @escaping (SearchResult) -> Void)

}

// MARK: - WeatherAPI
public class WeatherAPI: BaseAPI<WeatherNetworking>, WeatherProtocol {
    
    /// Initializes an instance of `WeatherAPI`.
    public override init() {}
    
    /// Retrieves the current weather information.
    ///
    /// - Parameters:
    ///   - request: The weather request parameters.
    ///   - completionHandler: A closure to be executed when the request finishes.
    public func getCurrentWeather(request: WeatherRequest, completionHandler: @escaping (CurrentWeather) -> Void) {
        self.fetchData(target: .getCurrentWeather(request: request), responseClass: WeatherResponse.self) { result in
            completionHandler(result)
        }
    }
    
    /// Fetches daily weather data based on the provided request.
    ///
    /// - Parameters:
    ///   - request: The weather request containing parameters for fetching daily weather data.
    ///   - completionHandler: A closure to be called once the data is fetched. It provides the fetched daily weather data.
    public func getDailyWeather(request: WeatherRequest, completionHandler: @escaping (HourlyForecast) -> Void) {
        self.fetchData(target: .getDailyWeather(request: request), responseClass: Forecast.self) { result in
            completionHandler(result)
        }
    }
    
    public func getWeatherBy(cityName: String, completionHandler: @escaping (SearchResult) -> Void) {
        self.fetchData(target: .getWeatherBy(query: cityName), responseClass: CityResult.self) { result in
            completionHandler(result)
        }
    }
}
