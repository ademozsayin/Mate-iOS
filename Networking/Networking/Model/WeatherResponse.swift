//
//  WeatherResponse.swift
//  Networking
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

// MARK: - WeatherResponse
public struct WeatherResponse: Codable {
    public let coord: Coord?
    public let weather: [Weather]?
    public let main: Main?
    public let name: String?
    public let cod: Int?
}

// MARK: - Coord
public struct Coord: Codable {
    public let lon, lat: Double
}

// MARK: - Main
public struct Main: Codable {
    public let temp: Double?

    enum CodingKeys: String, CodingKey {
        case temp
    }
}

// MARK: - Sys
public struct Sys: Codable {
    public let country: String
}

// MARK: - Weather
public struct Weather: Codable {
    public let id: Int
    public let main, description, icon: String
}
