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

// MARK: - WeatherProtocol
/// Protocol defining the interface for weather-related operations.
public protocol WeatherProtocol {
    
    /// Retrieves the current weather information.
    ///
    /// - Parameters:
    ///   - request: The weather request parameters.
    ///   - completionHandler: A closure to be executed when the request finishes.
    func getCurrentWeather(request: WeatherRequest, completionHandler: @escaping (CurrentWeather) -> Void)
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
}
