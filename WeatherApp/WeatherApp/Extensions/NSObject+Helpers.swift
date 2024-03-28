//
//  NSObject+Helpers.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 22.03.2024.
//

import ObjectiveC

/// NSObject: Helper Methods
///
///
extension NSObject {

    /// Returns the receiver's classname as a string, not including the namespace.
    ///
    class var classNameWithoutNamespaces: String {
        return String(describing: self)
    }
}
