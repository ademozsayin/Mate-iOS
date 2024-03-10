//
//  Forecast.swift
//  Networking
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation
import CodeGen
// MARK: - Forecast
public struct Forecast: Codable,  GeneratedCopiable, GeneratedFakeable  {
    public let message: Int?
    public let cod: String?
    public let cnt: Int?
    public let list: [List]?
    public let city: City?
    
    public init(message: Int?, cod: String?, cnt: Int?, list: [List]?, city: City?) {
        self.message = message
        self.cod = cod
        self.cnt = cnt
        self.list = list
        self.city = city
    }
}

// MARK: - List
public struct List: Codable,  GeneratedCopiable, GeneratedFakeable  {
    public let dt: Int?
    public let dtTxt: String?
    public let main: Main?
    public let weather: [Weather]?
    public let pop: Double?
   
    public let visibility: Int?
    
    public  init(dt: Int?, dtTxt: String?, main: Main?, weather: [Weather]?, pop: Double?, visibility: Int?) {
        self.dt = dt
        self.dtTxt = dtTxt
        self.main = main
        self.weather = weather
        self.pop = pop
        self.visibility = visibility
    }

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

