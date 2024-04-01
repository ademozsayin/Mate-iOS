//
//  Settings.swift
//  Networking
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation


/// Networking Preferences
///
public struct Settings {
    
    /// The BaseURL for the weather API.
    public static var baseURL: String {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("Base URL not found in Info.plist.")
        }
        return base
    }
    
    /// The API key suffix for the weather API.
    public static var appIdSuffix: String {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "WEATHER_API_KEY") as? String else {
            fatalError("Weather API key not found in Info.plist.")
        }
        return "\(key)"
    }
    
    /// WordPress.com API Base URL
    ///
    public static var onsastradaApiBaseURL: String = {
        if ProcessInfo.processInfo.arguments.contains("mocked-onsastrada-api") {
            return "http://localhost:8055/"
        } else if let onsaApiBaseURL = ProcessInfo.processInfo.environment["onsastrada-api-base-url"] {
            return onsaApiBaseURL
        }

        return baseURL//"https://public-api.wordpress.com/"
    }()
    
    /// onsa API Base URL
    /// Laravel 11 API
    public static var onsaApiBaseURL: String = {
        if ProcessInfo.processInfo.arguments.contains("mocked-onsa-api") {
            return "http://localhost:8000/"
        } else if let onsaApiBaseURL = ProcessInfo.processInfo.environment["onsa-api-url"] {
            return onsaApiBaseURL
        }

        return baseURL//"https://public-api.wordpress.com/"
    }()
}
