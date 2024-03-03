//
//  CityResult.swift
//  Networking
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import CodeGen

// MARK: - CityResult
public struct CityResult: Decodable,  GeneratedCopiable, GeneratedFakeable {
    public let base: String?
    public let id: Int?
    public let dt: Int?
    public let main: Main?
    public let coord: Coord?
    public let wind: Wind?
    public let sys: Sys?
    public let weather: [Weather]?
    public let visibility: Int?
    public let clouds: Clouds?
    public let timezone: Int?
    public let cod: Int?
    public let name: String?
    
    public init(base: String?, id: Int?, dt: Int?, main: Main?, coord: Coord?, wind: Wind?, sys: Sys?, weather: [Weather]?, visibility: Int?, clouds: Clouds?, timezone: Int?, cod: Int?, name: String?) {
        self.base = base
        self.id = id
        self.dt = dt
        self.main = main
        self.coord = coord
        self.wind = wind
        self.sys = sys
        self.weather = weather
        self.visibility = visibility
        self.clouds = clouds
        self.timezone = timezone
        self.cod = cod
        self.name = name
    }
}

// MARK: - Clouds
public struct Clouds: Decodable,  GeneratedCopiable, GeneratedFakeable {
    public let all: Int?
    public init(all: Int?) {
        self.all = all
    }
}

// MARK: - Sys
public struct Sys: Decodable,  GeneratedCopiable, GeneratedFakeable {
    public let id: Int?
    public let country: String?
    public let sunset: Int?
    public let type: Int?
    public let sunrise: Int?
    
    public init(id: Int?, country: String?, sunset: Int?, type: Int?, sunrise: Int?) {
        self.id = id
        self.country = country
        self.sunset = sunset
        self.type = type
        self.sunrise = sunrise
    }
}

// MARK: - Wind
public struct Wind: Decodable,  GeneratedCopiable, GeneratedFakeable {
    public let speed: Double?
    public let deg: Int?
    public let gust: Double?
    
    public init(speed: Double?, deg: Int?, gust: Double?) {
        self.speed = speed
        self.deg = deg
        self.gust = gust
    }
}
