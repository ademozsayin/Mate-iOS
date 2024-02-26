//
//  AuthNetworking.swift
//  Network
//
//  Created by Adem Özsayın on 26.02.2024.
//


import Foundation
import Alamofire

/// Enum representing weather networking endpoints.
public enum WeatherNetworking {
    
    /// Retrieves current weather information.
    case getCurrentWeather(request: WeatherRequest)
}

extension WeatherNetworking: TargetType {
    
    /// The base URL for weather networking requests.
    public var baseURL: String {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("Base URL not found in Info.plist.")
        }
        return base
    }
    
    /// The path for the weather networking request.
    public var path: String {
        switch self {
        case .getCurrentWeather(let request):
            return "weather?lat=\(request.latitude)&lon=\(request.longitude)/\(appIdSuffix)"
        }
    }
    
    /// The HTTP method for the weather networking request.
    public var method: HTTPMethod {
        switch self {
        case .getCurrentWeather:
            return .post
        }
    }
    
    /// The task for the weather networking request.
    public var task: HTTPTask {
        switch self {
        case .getCurrentWeather:
            return .requestPlain
        }
    }
    
    /// The headers for the weather networking request.
    public var headers: [String: String]? {
        return nil
    }
    
    /// The version of the weather API.
    private let version = "/data/2.5/"
    
    /// The API key suffix for the weather API.
    private var appIdSuffix: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String else {
            fatalError("Weather API key not found in Info.plist.")
        }
        return "appid=\(key)"
    }
}
