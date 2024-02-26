//
//  WeatherResponse.swift
//  Networking
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

// MARK: - WeatherResponse
public struct WeatherResponse: Codable {
    let coord: Coord?
    let weather: [Weather]?
    let main: Main?
    let wind: Wind?
    let name: String?
    let cod: Int?
}

// MARK: - Clouds
public struct Clouds: Codable {
    let all: Int
}

// MARK: - Coord
public struct Coord: Codable {
    let lon, lat: Double
}

// MARK: - Main
public struct Main: Codable {
    let temp, feelsLike, tempMin, tempMax: Double?
    let pressure, humidity, seaLevel, grndLevel: Double?

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
    let the1H: Double

    enum CodingKeys: String, CodingKey {
        case the1H = "1h"
    }
}

// MARK: - Sys
public struct Sys: Codable {
    let type, id: Int
    let country: String
    let sunrise, sunset: Int
}

// MARK: - Weather
public struct Weather: Codable {
    let id: Int
    let main, description, icon: String
}

// MARK: - Wind
public struct Wind: Codable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}
