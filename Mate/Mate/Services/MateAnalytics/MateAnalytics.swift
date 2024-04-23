//
//  MateAnalytics.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation
import Alamofire
import UIKit
import WidgetKit

class MateAnalytics: MateAnalyticsProtocol {
    
    /// Time when app was opened — used for calculating the time-in-app property
    ///
    private var applicationOpenedTime: Date?

    /// Check user opt-in for analytics
    ///
    var userHasOptedIn: Bool {
        get {
            let isUITesting: Bool = CommandLine.arguments.contains("-ui_testing")
            let optedIn: Bool? = UserDefaults.standard.object(forKey: .userOptedInAnalytics)
            return ( optedIn ?? true ) && !isUITesting // analytics tracking on by default, but disabled for UI tests
        }
        set {
            UserDefaults.standard.set(newValue, forKey: .userOptedInAnalytics)
        }
    }
    
    internal var analyticsProvider: MateAnalyticsProvider
    
    init(provider: MateAnalyticsProvider) {
        self.analyticsProvider = provider
    }
    
    func initialize() {}
    
    func refreshUserData() {}
    
    func setUserHasOptedOut(_ optedOut: Bool) {}
        
    /// Track a spcific event without any associated properties
    ///
    /// - Parameter stat: the event name
    ///
    func track(_ stat: MateAnalyticsStat) {
        guard userHasOptedIn == true else {
            return
        }

        track(stat, withProperties: nil)
    }

    /// Track a specific event with associated properties
    ///
    /// - Parameters:
    ///   - stat: the event name
    ///   - properties: a collection of properties related to the event
    ///
    func track(_ stat: MateAnalyticsStat, withProperties properties: [AnyHashable: Any]?) {
        track(stat, properties: properties, error: nil)
    }

    /// Track a specific event with an associated error (that is translated to properties)
    ///
    /// - Parameters:
    ///   - stat: the event name
    ///   - error: the error to track
    ///
    func track(_ stat: MateAnalyticsStat, withError error: Error) {
        track(stat, properties: nil, error: error)
    }

    /// Track a specific event with associated properties and an associated error (that is translated to properties)
    ///
    /// - Parameters:
    ///   - stat: the event name
    ///   - properties: a collection of properties related to the event
    ///   - error: the error to track
    ///
    func track(_ stat: MateAnalyticsStat, properties passedProperties: [AnyHashable: Any]?, error: Error?) {
        guard userHasOptedIn == true else {
            return
        }

        let properties = combinedProperties(from: error, with: passedProperties)

        if let updatedProperties = updatePropertiesIfNeeded(for: stat, properties: properties) {
            analyticsProvider.track(stat.rawValue, withProperties: updatedProperties)
        } else {
            analyticsProvider.track(stat.rawValue, withProperties: nil)
        }
    }

    private func combinedProperties(from error: Error?, with passedProperties: [AnyHashable: Any]?) -> [AnyHashable: Any]? {
        let properties: [AnyHashable: Any]?
        let errorProperties = errorProperties(from: error)

        if let passedProperties = passedProperties {
            properties = passedProperties.merging(errorProperties ?? [:], uniquingKeysWith: { current, _ in
                current
            })
        } else {
            properties = errorProperties
        }
        return properties
    }

    private func errorProperties(from error: Error?) -> [AnyHashable: Any]? {
        guard let error = error else {
            return nil
        }

        let err = error as NSError
        let errorCode: String = {
            if let networkError = error as? AFError {
                return "\(networkError.responseCode ?? 0)"
            } else if let loginError = error as? SiteCredentialLoginError {
                return "\(loginError.underlyingError.code)"
            }
            return "\(err.code)"
        }()
        let errorDomain = err.domain
        let errorDescription = err.description

        return [
            Constants.errorKeyCode: errorCode,
            Constants.errorKeyDomain: errorDomain,
            Constants.errorKeyDescription: errorDescription
        ]
    }
}



// MARK: - Private Helpers
//
private extension MateAnalytics {

    func startObservingNotifications() {
        guard userHasOptedIn == true else {
            return
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackApplicationOpened),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(trackApplicationClosed),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }

    @objc func trackApplicationOpened() {
        WidgetCenter.shared.getCurrentConfigurations { [weak self] configurationResult in
            guard let self = self else { return }
//            self.track(.applicationOpened, withProperties: self.applicationOpenedProperties(configurationResult))
        }
        applicationOpenedTime = Date()
    }

    @objc func trackApplicationClosed() {
        track(.applicationClosed, withProperties: applicationClosedProperties())
        applicationOpenedTime = nil
    }

    func applicationClosedProperties() -> [String: Any]? {
        guard let applicationOpenedTime = applicationOpenedTime else {
            return nil
        }

        let timeInApp = round(Date().timeIntervalSince(applicationOpenedTime))
        return [PropertyKeys.propertyKeyTimeInApp: timeInApp.description]
    }

    /// This function appends any additional properties to the provided properties dict if needed.
    ///
    func updatePropertiesIfNeeded(for stat: MateAnalyticsStat, properties: [AnyHashable: Any]?) -> [AnyHashable: Any]? {
        guard stat.shouldSendSiteProperties, ServiceLocator.stores.isAuthenticated else {
            return properties
        }

        var updatedProperties = properties ?? [:]
//        let site = ServiceLocator.stores.sessionManager.defaultSite
//        updatedProperties[PropertyKeys.siteURL] = site?.url
        updatedProperties[PropertyKeys.userID] = ServiceLocator.stores.sessionManager.defaultAccountID
//        updatedProperties[PropertyKeys.email] = ServiceLocator.stores.sessionManager.defaultAccount?.email

        return updatedProperties
    }

    /// Builds the necesary properties for the `application_opened` event.
    ///
//    func applicationOpenedProperties(_ configurationResult: Result<[WidgetInfo], Error>) -> [String: String] {
//        guard let installedWidgets = try? configurationResult.get() else {
//            return ["widgets": ""]
//        }
//
//        // Translate the widget kind into a name recognized by tracks.
//        let widgetAnalyticNames: [String] = installedWidgets.map { widgetInfo in
//            switch widgetInfo.kind {
//            case FiableConstants.storeInfoWidgetKind:
//                return "\(MateAnalyticsEvent.Widgets.Name.todayStats.rawValue)-\(widgetInfo.family)"
//            case FiableConstants.appLinkWidgetKind:
//                return MateAnalyticsEvent.Widgets.Name.appLink.rawValue
//            default:
//                DDLogWarn("⚠️ Make sure the widget: \(widgetInfo.kind), has the correct tracks name.")
//                return widgetInfo.kind
//            }
//        }
//
//        return ["widgets": widgetAnalyticNames.joined(separator: ",")]
//    }
}



// MARK: - Constants!
//
private extension MateAnalytics {

    enum Constants {
        static let errorKeyCode         = "error_code"
        static let errorKeyDomain       = "error_domain"
        static let errorKeyDescription  = "error_description"
    }

    enum PropertyKeys {
        static let propertyKeyTimeInApp = "time_in_app"
        static let userID = "user_id"
        static let email = "email"

    }
}
