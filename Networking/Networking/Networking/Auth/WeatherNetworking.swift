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
        return Settings.baseURL
    }
    
    /// The path for the weather networking request.
    public var path: String {
        switch self {
        case .getCurrentWeather(let request):
            return "\(version)/weather?lat=\(request.latitude)&lon=\(request.longitude)&\(appIdSuffix)"
        }
    }
    
    /// The HTTP method for the weather networking request.
    public var method: HTTPMethod {
        switch self {
        case .getCurrentWeather:
            return .get
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
    private var version:String {
        return "/data/2.5/"
    }
    
    /// The API key suffix for the weather API.
    private var appIdSuffix: String {
        return "appid=\(Settings.appIdSuffix)"
    }
}
