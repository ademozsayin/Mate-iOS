//
//  FirebaseAnalyticsService.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation
import FirebaseAnalytics

class FirebaseAnalyticsService: MateAnalyticsService {
    
    func logEvent(_ eventName: String, parameters: [String : Any]) {
        Analytics.logEvent(eventName, parameters: parameters)
    }
    
    func logEvent(_ eventName: String, parameters: [String: Any]? ) {
        Analytics.logEvent(eventName, parameters: parameters)
    }
    
    func logEvent(_ eventName: String, parameters: [AnyHashable : Any]? ) {
        if let stringDictionary = parameters?.toStringKeyDictionary() {
            Analytics.logEvent(eventName, parameters: stringDictionary)
        }
    }
}

extension Dictionary where Key == AnyHashable {
    func toStringKeyDictionary() -> [String: Value]? {
        guard let dictionary = self as? [String: Value] else {
            return nil
        }
        return dictionary
    }
}
