//
//  AnalyticsEvent.swift
//  
//
//  Created by Adem Özsayın on 19.03.2024.
//

import Foundation
/// This struct represents an analytics event.
/// Declaring this class as final is a design choice to promote a simpler usage and implement events
/// through parametrization of the `name` and `properties` properties.
///
/// An example of a static event definition (in the client App or Pod):
///
/// ~~~
/// extension AnalyticsEvent {
///     static let loginStart = AnalyticsEvent(name: "login", properties: ["step": "start"])
/// }
/// ~~~
///
/// An example of a dynamic / parametrized event definition (in the client App or Pod):
///
/// ~~~
/// extension AnalyticsEvent {
///     enum LoginStep: String {
///         case start
///         case success
///     }
///
///     static func login(step: LoginStep) -> AnalyticsEvent {
///         let properties = [
///             "step": step.rawValue
///         ]
///
///         return AnalyticsEvent(name: "login", properties: properties)
///     }
/// }
/// ~~~
///
/// Examples of tracking calls (in the client App or Pod):
///
/// ~~~
/// WPAnalytics.track(.login(step: .start))
/// WPAnalytics.track(.loginStart)
/// ~~~
///
public final class AnalyticsEvent {
    public let name: String
    public let properties: [String: String]

    public init(name: String, properties: [String: String]) {
        self.name = name
        self.properties = properties
    }
}

extension FiableAnalytics {
    public static func track(_ event: AnalyticsEvent) {
        FiableAnalytics.trackString(event.name, with: event.properties)
    }
}
