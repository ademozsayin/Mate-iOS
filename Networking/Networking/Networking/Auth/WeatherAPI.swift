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
public typealias DailyWeather = Result<DailyWeatherResponse, NSError>

// MARK: - WeatherProtocol
/// A protocol defining methods to retrieve weather information.
public protocol WeatherProtocol {
    
    /// Retrieves the current weather information.
    ///
    /// - Parameters:
    ///   - request: The weather request parameters.
    ///   - completionHandler: A closure to be executed when the request finishes. It provides the current weather data.
    func getCurrentWeather(request: WeatherRequest, completionHandler: @escaping (CurrentWeather) -> Void)
    
    /// Retrieves daily weather information.
    ///
    /// - Parameters:
    ///   - request: The weather request parameters.
    ///   - completionHandler: A closure to be executed when the request finishes. It provides the daily weather data.
    func getDailyWeather(request: WeatherRequest, completionHandler: @escaping (DailyWeather) -> Void)
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
    public func getDailyWeather(request: WeatherRequest, completionHandler: @escaping (DailyWeather) -> Void) {
        self.fetchData(target: .getDailyWeather(request: request), responseClass: DailyWeatherResponse.self) { result in
            completionHandler(result)
        }
    }
}
