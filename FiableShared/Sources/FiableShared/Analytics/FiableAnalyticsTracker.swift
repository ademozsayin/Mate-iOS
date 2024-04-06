//
//  FiableAnalyticsTracker.swift
//  
//
//  Created by Adem Özsayın on 19.03.2024.
//

import Foundation

// Protocol for Analytics Tracker
public protocol FiableAnalyticsTracker {
    func beginTimer(for stat: FiableAnalyticsStat)
    func endTimer(for stat: FiableAnalyticsStat, with properties: [String: Any])
    func track(_ stat: FiableAnalyticsStat)
    func track(_ stat: FiableAnalyticsStat, with properties: [String: Any])
    func trackString(_ event: String)
    func trackString(_ event: String, with properties: [String: Any])
    func beginSession()
    func endSession()
    func refreshMetadata()
    func clearQueuedEvents()
}
//

//@objc public protocol FiableAnalyticsTracker {
//    func track(_ stat: FiableAnalyticsStat)
//    func track(_ stat: FiableAnalyticsStat, withProperties properties: [AnyHashable: Any])
//    func trackString(_ event: String)
//    func trackString(_ event: String, withProperties properties: [AnyHashable: Any])
//    
//    @objc optional func beginSession()
//    @objc optional func endSession()
//    @objc optional func refreshMetadata()
//    @objc optional func beginTimer(for stat: FiableAnalyticsStat)
//    @objc optional func endTimer(for stat: FiableAnalyticsStat, withProperties properties: [AnyHashable: Any])
//    @objc optional func clearQueuedEvents()
//}
