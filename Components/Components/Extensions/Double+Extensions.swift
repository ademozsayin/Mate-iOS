//
//  Double+Extensions.swift
//  Components
//
//  Created by Adem Özsayın on 28.02.2024.
//

import Foundation

extension Double {
    /// Converts the double value to a string representation with the degree symbol and the specified unit.
    /// - Parameters:
    ///   - unit: The unit of temperature (e.g., "C" for Celsius, "F" for Fahrenheit).
    /// - Returns: A string representation of the temperature.
    func temperatureString(unit: String = "F") -> String {
        let degreeSymbol = "\u{00B0}"
        let roundedTemperature = Int(self.rounded())
        return "\(roundedTemperature)\(degreeSymbol)\(unit)"
    }
    
    /// Converts the double value to Celsius.
    func toCelsius() -> Double {
        return (self - 32) * 5/9
    }
}

