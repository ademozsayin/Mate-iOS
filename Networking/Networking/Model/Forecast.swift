//
//  Forecast.swift
//  Networking
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

// MARK: - Forecast
public struct Forecast: Codable {
    public let message: Int?
    public let cod: String?
    public let cnt: Int?
    public let list: [List]?
    public let city: City?
}

// MARK: - Clouds
public struct Clouds: Codable {
    public let all: Int?

    public init(all: Int?) {
        self.all = all
    }
}

// MARK: - MainClass
public struct MainClass: Codable {
    public let humidity: Int?
    public let feelsLike, tempMin, tempMax, temp: Double?
    public let pressure: Int?
    public let tempKf: Double?
    public let seaLevel, grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case temp, pressure
        case tempKf = "temp_kf"
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }

    public init(humidity: Int?, feelsLike: Double?, tempMin: Double?, tempMax: Double?, temp: Double?, pressure: Int?, tempKf: Double?, seaLevel: Int?, grndLevel: Int?) {
        self.humidity = humidity
        self.feelsLike = feelsLike
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.temp = temp
        self.pressure = pressure
        self.tempKf = tempKf
        self.seaLevel = seaLevel
        self.grndLevel = grndLevel
    }
}

// MARK: - Rain
public struct Rain: Codable {
    public let the3H: Double?

    enum CodingKeys: String, CodingKey {
        case the3H = "3h"
    }

    public init(the3H: Double?) {
        self.the3H = the3H
    }
}


public enum Pod: String, Codable {
    case d = "d"
    case n = "n"
}

public enum Description: String, Codable {
    case brokenClouds = "broken clouds"
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case lightRain = "light rain"
    case overcastClouds = "overcast clouds"
    case scatteredClouds = "scattered clouds"
}

public enum MainEnum: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
}

// MARK: - Wind
public struct Wind: Codable {
    public let speed: Double?
    public let deg: Int?
    public let gust: Double?

    public init(speed: Double?, deg: Int?, gust: Double?) {
        self.speed = speed
        self.deg = deg
        self.gust = gust
    }
}
