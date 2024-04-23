//
//  MateAnalyticsProvider.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

public protocol MateAnalyticsProvider {
    func trackEvent(_ eventName: String, parameters: [String: Any]?)
    func refreshUserData()
    func clearEvents()
    func clearUsers()
    func track(_ eventName: String, withProperties properties: [AnyHashable: Any]?)

}
