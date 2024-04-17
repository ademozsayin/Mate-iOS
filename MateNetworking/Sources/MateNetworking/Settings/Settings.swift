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
    
    /// The BaseURL for the Onsa Mate API.
    public static var baseURL: String {
        guard let base = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String else {
            fatalError("Base URL not found in Info.plist.")
        }
        return base
    }
    
    /// onsa API Base URL
    /// Laravel 11 API
    public static var onsaApiBaseURL: String = {
        if ProcessInfo.processInfo.arguments.contains("localhost") {
            return "http://192.168.1.214:8000/"
        } else if let onsaApiBaseURL = ProcessInfo.processInfo.environment["development"] {
            return "https:/development.fiable.agency/"
        } else if let onsaApiBaseURL = ProcessInfo.processInfo.environment["staging"] {
            return onsaApiBaseURL
        }

        return baseURL
    }()
}
