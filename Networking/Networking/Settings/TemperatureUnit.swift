//
//  TemperatureUnit.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

public enum TemperatureUnit: String {
    case celsius = "C"
    case fahrenheit = "F"
    
    // Convenience method to get the current temperature unit from UserDefaults
    public static var currentUnit: TemperatureUnit {
        if let savedUnit = UserDefaults.standard.string(forKey: "TemperatureUnit"),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            return unit
        } else {
            // Default to Fahrenheit if no preference is found
            return .fahrenheit
        }
    }
    
    // Convenience method to save the selected temperature unit to UserDefaults
    public func save() {
        UserDefaults.standard.set(rawValue, forKey: "TemperatureUnit")
    }
}
