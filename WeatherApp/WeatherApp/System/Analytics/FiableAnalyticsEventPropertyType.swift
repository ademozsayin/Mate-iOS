//
//  FiableAnalyticsEventPropertyType.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 20.03.2024.
//

import Foundation

/// A valid type that is accepted by Tracks to be used for custom properties.
///
/// Looking at Tracks' UI, the accepted properties are:
///
/// - string
/// - integer
/// - float
/// - boolean
///
protocol FiableAnalyticsEventPropertyType {

}

extension String: FiableAnalyticsEventPropertyType {

}

extension Int64: FiableAnalyticsEventPropertyType {

}

extension Float64: FiableAnalyticsEventPropertyType {

}

extension Bool: FiableAnalyticsEventPropertyType {

}

extension Int: FiableAnalyticsEventPropertyType {}
