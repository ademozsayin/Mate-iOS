//
//  TracksProvider.swift
//  Mate
//
//  Created by Adem Özsayın on 22.03.2024.
//

import Foundation
import FiableRedux
import AutomatticTracks
import FiableShared


public class TracksProvider: NSObject, AnalyticsProvider {
    private static let contextManager: TracksContextManager = TracksContextManager()

    private static let tracksService: TracksService = {
        let tracksService = TracksService(contextManager: contextManager)!
        tracksService.eventNamePrefix = Constants.eventNamePrefix
        return tracksService
    }()
}


// MARK: - AnalyticsProvider Conformance
//
public extension TracksProvider {
    func refreshUserData() {
        switchTracksUsersIfNeeded()
        refreshTracksMetadata()
    }

    func track(_ eventName: String) {
        track(eventName, withProperties: nil)
    }

    func track(_ eventName: String, withProperties properties: [AnyHashable: Any]?) {
        if let properties {
            guard Self.tracksService.trackEventName(eventName, withCustomProperties: properties) else {
                return DDLogError("🔴 Error tracking \(eventName) with properties: \(properties)")
            }
            DDLogInfo("🔵 Tracked \(eventName), properties: \(properties)")
        } else {
            Self.tracksService.trackEventName(eventName)
            DDLogInfo("🔵 Tracked \(eventName)")
        }
    }

    func clearEvents() {
        Self.tracksService.clearQueuedEvents()
    }

    /// When a user opts-out, wipe data
    ///
    func clearUsers() {
        guard ServiceLocator.analytics.userHasOptedIn else {
            // To be safe, nil out the anonymousUserID guid so a fresh one is regenerated
            UserDefaults.standard[.defaultAnonymousID] = nil
            UserDefaults.standard[.analyticsUsername] = nil
            Self.tracksService.switchToAnonymousUser(withAnonymousID: "1")
//            Self.tracksService.switchToAnonymousUser(withAnonymousID: ServiceLocator.stores.sessionManager.anonymousUserID)
            return
        }

        switchTracksUsersIfNeeded()
    }
}


// MARK: - Private Helpers
//
private extension TracksProvider {
    func switchTracksUsersIfNeeded() {
        let currentAnalyticsUsername = UserDefaults.standard[.analyticsUsername] as? String ?? ""
        let anonymousID = "1"//ServiceLocator.stores.sessionManager.anonymousUserID
        if ServiceLocator.stores.isAuthenticated,
           let account = ServiceLocator.stores.sessionManager.defaultAccount,
           case let .wpcom(_, authToken, _) = ServiceLocator.stores.sessionManager.defaultCredentials {
            if currentAnalyticsUsername.isEmpty {
                // No previous username logged
                UserDefaults.standard[.analyticsUsername] = account.name
                Self.tracksService.switchToAuthenticatedUser(withUsername: account.name,
                                                             userID: String(account.userID),
                                                             wpComToken: authToken,
                                                             skipAliasEventCreation: false)
            } else if currentAnalyticsUsername == account.name {
                // Username did not change - just make sure Tracks client has it
                Self.tracksService.switchToAuthenticatedUser(withUsername: account.name,
                                                             userID: String(account.userID),
                                                             wpComToken: authToken,
                                                             skipAliasEventCreation: true)
            } else {
                // Username changed for some reason - switch back to anonymous first
                Self.tracksService.switchToAnonymousUser(withAnonymousID: anonymousID)
                Self.tracksService.switchToAuthenticatedUser(withUsername: account.name,
                                                             userID: String(account.userID),
                                                             wpComToken: authToken,
                                                             skipAliasEventCreation: false)
            }
        } else {
            UserDefaults.standard[.analyticsUsername] = nil
            Self.tracksService.switchToAnonymousUser(withAnonymousID: anonymousID)
        }
    }

    func refreshTracksMetadata() {
        DDLogInfo("♻️ Refreshing tracks metadata...")
        var userProperties = [String: Any]()
        userProperties[UserProperties.platformKey] = "iOS"
        userProperties[UserProperties.voiceOverKey] = UIAccessibility.isVoiceOverRunning
        userProperties[UserProperties.rtlKey] = (UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft)
        Self.tracksService.userProperties.removeAllObjects()
        Self.tracksService.userProperties.addEntries(from: userProperties)
    }
}


// MARK: - Constants!
//
private extension TracksProvider {

    enum Constants {
        static let eventNamePrefix = "woocommerceios"
    }

    enum UserProperties {
        static let platformKey          = "platform"
        static let voiceOverKey         = "accessibility_voice_over_enabled"
        static let rtlKey               = "is_rtl_language"
    }
}

extension TracksProvider: FiableAnalyticsTracker {
   
  
    public func beginTimer(for stat: FiableShared.FiableAnalyticsStat) {}
    public func endTimer(for stat: FiableShared.FiableAnalyticsStat, with properties: [String : Any]) {}
    public func trackString(_ event: String) {}
    public func trackString(_ event: String, with properties: [String : Any]) {}
    public func beginSession() {}
    public func endSession() {}
    public func refreshMetadata() {}
    public func clearQueuedEvents() {}

    public func trackString(_ event: String?) {
        trackString(event, withProperties: nil)
    }

    public func trackString(_ event: String?, withProperties properties: [AnyHashable: Any]?) {
        guard let eventName = event else {
            DDLogInfo("🔴 Attempted to track an event without name.")
            return
        }

        track(eventName, withProperties: properties)
    }

    public func track(_ stat: FiableAnalyticsStat) {
        // no op.
        track(stat, withProperties: nil)
    }

    public func track(_ stat: FiableAnalyticsStat, withProperties properties: [AnyHashable: Any]?) {
        // no op
    }
    
    public func track(_ stat: FiableShared.FiableAnalyticsStat, with properties: [String : Any]) {
        // no op
    }
}