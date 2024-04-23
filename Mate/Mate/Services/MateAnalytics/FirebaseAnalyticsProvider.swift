//
//  FirebaseAnalyticsProvider.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

class FirebaseAnalyticsProvider: MateAnalyticsProvider {
    func trackEvent(_ eventName: String, parameters: [String : Any]?) {
        FirebaseAnalyticsService().logEvent(eventName, parameters: parameters)
    }
    
    func track(_ eventName: String, withProperties properties: [AnyHashable : Any]?) {
        FirebaseAnalyticsService().logEvent(eventName, parameters: properties ?? [:])
    }
    
    func refreshUserData() {
        // Implementation for refreshing user data in Firebase Analytics
    }
    
    func clearEvents() {
        // Implementation for clearing events in Firebase Analytics
    }
    
    func clearUsers() {
        // Implementation for clearing users in Firebase Analytics
    }
}
