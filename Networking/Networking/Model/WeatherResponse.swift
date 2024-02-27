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
    public let wind: Wind?
    public let name: String?
    public let cod: Int?
}

// MARK: - Clouds
public struct Clouds: Codable {
    public let all: Int
}

// MARK: - Coord
public struct Coord: Codable {
    public let lon, lat: Double
}

// MARK: - Main
public struct Main: Codable {
    public let temp, feelsLike, tempMin, tempMax: Double?
    public let pressure, humidity, seaLevel, grndLevel: Double?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Rain
public struct Rain: Codable {
    public let the1H: Double

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}

// MARK: - Sys
public struct Sys: Codable {
    public let type, id: Int
    public let country: String
    public let sunrise, sunset: Int
}

// MARK: - Weather
public struct Weather: Codable {
    public let id: Int
    public let main, description, icon: String
}

// MARK: - Wind
public struct Wind: Codable {
    public let speed: Double?
    public let deg: Int?
    public let gust: Double?
}
