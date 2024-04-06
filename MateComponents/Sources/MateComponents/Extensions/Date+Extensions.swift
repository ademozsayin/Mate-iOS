//
//  Date+Extensions.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

/**
 Extension providing functionality related to Date objects.
 */
extension Date {
    
    /**
     Formats the date in a weather-related format (e.g., "Saturday - Feb 10").
     
     - Returns: A string representing the formatted date.
     */
    func asWeatherDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE - MMM d"
        return dateFormatter.string(from: self)
    }
}
