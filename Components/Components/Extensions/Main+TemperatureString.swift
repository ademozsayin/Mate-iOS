//
//  Main+TemperatureString.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation
import Networking

public extension Main {
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
