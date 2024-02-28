//
//  Date+Extensions.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

extension Date {
    
    func asWeatherDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE - MMM d"
        return dateFormatter.string(from: self)
    }
}
