//
//  FiableAnalytics.swift
//
//
//  Created by Adem Özsayın on 19.03.2024.
//

import Foundation

// Analytics Manager
public class FiableAnalytics {
    // Static trackers array
    static var trackers: [FiableAnalyticsTracker] = []

    // Register Tracker
    public static func registerTracker(_ tracker: FiableAnalyticsTracker) {
        trackers.append(tracker)
    }

    // Clear Trackers
    public static func clearTrackers() {
        trackers.removeAll()
    }

    // Begin Timer for Stat
    public static func beginTimer(for stat: FiableAnalyticsStat) {
        for tracker in trackers {
            tracker.beginTimer(for: stat)
        }
    }

    // End Timer for Stat
    public static func endTimer(for stat: FiableAnalyticsStat, with properties: [String: Any]) {
        for tracker in trackers {
            tracker.endTimer(for: stat, with: properties)
        }
    }

    // Track Stat
    public  static func track(_ stat: FiableAnalyticsStat) {
        for tracker in trackers {
            tracker.track(stat)
        }
    }

    // Track Stat with Properties
    public static func track(_ stat: FiableAnalyticsStat, with properties: [String: Any]) {
        for tracker in trackers {
            tracker.track(stat, with: properties)
        }
    }

    // Track String Event
    public  static func trackString(_ event: String) {
        for tracker in trackers {
            tracker.trackString(event)
        }
    }

    // Track String Event with Properties
    public static func trackString(_ event: String, with properties: [String: Any]) {
        for tracker in trackers {
            tracker.trackString(event, with: properties)
        }
    }

    // Begin Session
    public static func beginSession() {
        for tracker in trackers {
            tracker.beginSession()
        }
    }

    // End Session
    public static func endSession() {
        for tracker in trackers {
            tracker.endSession()
        }
    }

    // Refresh Metadata
    public static func refreshMetadata() {
        for tracker in trackers {
            tracker.refreshMetadata()
        }
    }

    // Clear Queued Events
    public static func clearQueuedEvents() {
        for tracker in trackers {
            tracker.clearQueuedEvents()
        }
    }
}
