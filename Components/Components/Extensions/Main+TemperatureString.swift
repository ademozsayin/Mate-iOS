//
//  Main+TemperatureString.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation
import Networking
/**
 Extension providing temperature-related formatting for the `Main` structure.
 */

public extension Main {
    
    /**
     Returns a string representing the min-max temperature range.
     
     - Parameter unit: The temperature unit (Celsius or Fahrenheit).
     - Returns: A string representing the min-max temperature range.
     */
    func minMaxTemperatureString(unit: TemperatureUnit) -> String? {
        guard let minTemp = temp_min, let maxTemp = temp_max else {
            return nil
        }
        
        let unitSymbol = unit == .celsius ? "°C" : "°F"
        let formatTemp: (Double) -> String = { temperature in
            return String(format: "%.0f", unit == .celsius ? temperature : (temperature * 9/5) + 32)
        }
        
        let minTempFormatted = formatTemp(minTemp)
        let maxTempFormatted = formatTemp(maxTemp)
        
        return "\(minTempFormatted)\(unitSymbol)-\(maxTempFormatted)\(unitSymbol)"
    }
    
    /**
     Returns a string representing the temperature.
     
     - Parameter unit: The temperature unit (Celsius or Fahrenheit).
     - Returns: A string representing the temperature.
     */
    func temperatureString(unit: TemperatureUnit) -> String? {
        guard let temp else {
            return nil
        }
        
        let unitSymbol = unit == .celsius ? "°C" : "°F"
        let formatTemp: (Double) -> String = { temperature in
            return String(format: "%.0f", unit == .celsius ? temperature : (temperature * 9/5) + 32)
        }
        
        return "\(formatTemp(temp))\(unitSymbol)"
    }
}
