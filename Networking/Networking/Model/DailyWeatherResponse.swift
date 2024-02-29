//
//  DaylyWeatherResponse.swift
//  Networking
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation


// MARK: - DailyWeatherResponse
public struct DailyWeatherResponse: Codable {
    public let city: City?
    public let cod: String?
    public let message: Double?
    public let cnt: Int?
    public let list: [List]?
}

// MARK: - City
public struct City: Codable {
    public let id: Int?
    public let name: String?
    public let coord: Coord?
    public let country: String?
    public let population, timezone: Int?
}

// MARK: - List
public struct List: Codable {
    public let dt, sunrise, sunset: Int?
    public let temp: Temp?
    public let feelsLike: FeelsLike?
    public let pressure, humidity: Int?
    public let weather: [Weather]?
    public let speed: Double?
    public let deg: Int?
    public let gust: Double?
    public let clouds: Int?
    public let pop, rain: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case feelsLike = "feels_like"
        case pressure, humidity, weather, speed, deg, gust, clouds, pop, rain
    }
}

// MARK: - FeelsLike
public struct FeelsLike: Codable {
    public let day, night, eve, morn: Double?
}

// MARK: - Temp
public struct Temp: Codable {
    public let day, min, max, night: Double?
    public let eve, morn: Double?
}
