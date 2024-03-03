//
//  City.swift
//  Networking
//
//  Created by Adem Özsayın on 3.03.2024.
//

import Foundation


// MARK: - City
public struct City: Codable,  GeneratedCopiable, GeneratedFakeable  {
    public let sunset: Int?
    public let country: String?
    public let id: Int?
    public let coord: Coord?
    public let population, timezone, sunrise: Int?
    public let name: String?

    public init(sunset: Int?, country: String?, id: Int?, coord: Coord?, population: Int?, timezone: Int?, sunrise: Int?, name: String?) {
        self.sunset = sunset
        self.country = country
        self.id = id
        self.coord = coord
        self.population = population
        self.timezone = timezone
        self.sunrise = sunrise
        self.name = name
    }
}
