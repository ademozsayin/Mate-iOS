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
