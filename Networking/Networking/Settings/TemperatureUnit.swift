//
//  TemperatureUnit.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

/**
 Enum representing temperature units, Celsius and Fahrenheit.
 */
public enum TemperatureUnit: String {
    
    /// Celsius temperature unit.
    case celsius = "C"
    
    /// Fahrenheit temperature unit.
    case fahrenheit = "F"
    
    /**
     Returns the current temperature unit saved in UserDefaults.
     
     - Returns: The current temperature unit.
     */
    public static var currentUnit: TemperatureUnit {
        if let savedUnit = UserDefaults.standard.string(forKey: "TemperatureUnit"),
           let unit = TemperatureUnit(rawValue: savedUnit) {
            return unit
        } else {
            // Default to Fahrenheit if no preference is found
            return .fahrenheit
        }
    }
    
    /**
     Saves the selected temperature unit to UserDefaults.
     */
    public func save() {
        UserDefaults.standard.set(rawValue, forKey: "TemperatureUnit")
    }
}
