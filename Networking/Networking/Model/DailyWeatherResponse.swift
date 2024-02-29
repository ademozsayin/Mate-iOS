//
//  DaylyWeatherResponse.swift
//  Networking
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation


// MARK: - DailyWeatherResponse
public struct DailyWeatherResponse: Codable {
    let city: City?
    let cod: String?
    let message: Double?
    let cnt: Int?
    let list: [List]?
}

// MARK: - City
public struct City: Codable {
    let id: Int?
    let name: String?
    let coord: Coord?
    let country: String?
    let population, timezone: Int?
}

// MARK: - List
public struct List: Codable {
    let dt, sunrise, sunset: Int?
    let temp: Temp?
    let feelsLike: FeelsLike?
    let pressure, humidity: Int?
    let weather: [Weather]?
    let speed: Double?
    let deg: Int?
    let gust: Double?
    let clouds: Int?
    let pop, rain: Double?

    enum CodingKeys: String, CodingKey {
        case dt, sunrise, sunset, temp
        case feelsLike = "feels_like"
        case pressure, humidity, weather, speed, deg, gust, clouds, pop, rain
    }
}

// MARK: - FeelsLike
public struct FeelsLike: Codable {
    let day, night, eve, morn: Double?
}

// MARK: - Temp
public struct Temp: Codable {
    let day, min, max, night: Double?
    let eve, morn: Double?
}
