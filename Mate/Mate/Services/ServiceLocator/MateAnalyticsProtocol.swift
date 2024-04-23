//
//  Analytics.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

/// Abstracts the Analytics engine.
///
protocol MateAnalyticsProtocol {
    /// Initialize the analytics engine
    ///
    func initialize()

    /// Track a specific event without any associated properties
    ///
    /// - Parameter stat: the event name
    ///
    func track(_ stat: MateAnalyticsStat)

    /// Track a specific event with associated properties
    ///
    /// - Parameters:
    ///   - stat: the event name
    ///   - properties: a collection of properties related to the event
    ///
    func track(_ stat: MateAnalyticsStat, withProperties properties: [AnyHashable: Any]?)

    /// Track a specific event with an associated error (that is translated to properties)
    ///
    /// - Parameters:
    ///   - stat: the event name
    ///   - error: the error to track
    ///
    func track(_ stat: MateAnalyticsStat, withError error: Error)

    /// Track a specific event with associated properties and an associated error (that is translated to properties)
    ///
    /// - Parameters:
    ///   - stat: the event name
    ///   - properties: a collection of properties related to the event
    ///   - error: the error to track
    ///
    func track(_ stat: MateAnalyticsStat, properties: [AnyHashable: Any]?, error: Error?)

    /// Refresh the tracking metadata for the currently logged-in or anonymous user.
    /// It's good to call this function after a user logs in or out of the app.
    ///
    func refreshUserData()

    /// Sets the boolean flag to signal that the user has opted out of analytics
    /// It will trigger a call to `refreshUserData` before starting tracking again.
    ///
    /// - Parameters:
    ///   - optedOut: Boolean flag. If true, we stop tracking.
    func setUserHasOptedOut(_ optedOut: Bool)

    /// Check user opt-in for analytics
    ///
    var userHasOptedIn: Bool { get set }

    /// AnalyticsProvider: Interface to the actual analytics implementation
    ///
    var analyticsProvider: MateAnalyticsProvider { get }
}

extension MateAnalyticsProtocol {
    /// Track a specific event.
    ///
    /// - Parameter event: The event to track along with its properties.
    ///
    func track(event: MateAnalyticsEvent) {
        track(event.name, properties: event.properties, error: event.error)
    }
}
