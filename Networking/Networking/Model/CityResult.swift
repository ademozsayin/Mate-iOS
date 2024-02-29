//
//  CityResult.swift
//  Networking
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation

// MARK: - CityResult
public struct CityResult: Decodable {
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
}

// MARK: - Clouds
public struct Clouds: Decodable {
    public let all: Int?
}

// MARK: - Sys
public struct Sys: Decodable {
    public let id: Int?
    public let country: String?
    public let sunset: Int?
    public let type: Int?
    public let sunrise: Int?
}

// MARK: - Wind
public struct Wind: Decodable {
    public let speed: Double?
    public let deg: Int?
    public let gust: Double?
}
