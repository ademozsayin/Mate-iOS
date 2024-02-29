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

// MARK: - City
public struct City: Codable {
    public let sunset: Int?
    public let country: String?
    public let id: Int?
    public let coord: Coord?
    public let population, timezone, sunrise: Int?
    public let name: String?

}

// MARK: - List
public struct List: Codable {
    public let dt: Int?
    public let dtTxt: String?
    public let main: Main?
    public let weather: [Weather]?
    public let pop: Double?
   
    public let visibility: Int?

    enum CodingKeys: String, CodingKey {
        case dt
        case dtTxt = "dt_txt"
        case main, weather, pop, visibility
    }
    
    // Function to convert dtTxt to time format (HH:mm)
    public func getTimeFromDtTxt() -> String? {
        guard let dtTxt = self.dtTxt else { return nil }
        
        // Create a DateFormatter to parse the datetime string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        // Parse the datetime string into a Date object
        if let date = dateFormatter.date(from: dtTxt) {
            // Create another DateFormatter to format the Date object to the desired format
            let timeFormatter = DateFormatter()
            timeFormatter.dateFormat = "HH:mm"
            
            // Format the Date object to a string with the desired time format
            return timeFormatter.string(from: date)
        } else {
            return nil
        }
    }
}

