//
//  MateAnalyticsEvent.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation


public struct MateAnalyticsEvent {
    let name: MateAnalyticsStat
    let properties: [String: MateAnalyticsEventPropertyType]?
    let error: Error?
    
    init(name: MateAnalyticsStat, properties: [String : MateAnalyticsEventPropertyType]?, error: Error? = nil) {
        self.name = name
        self.properties = properties
        self.error = error
    }
}

protocol MateAnalyticsEventPropertyType {}

extension String: MateAnalyticsEventPropertyType {}

extension Int64: MateAnalyticsEventPropertyType {}

extension Float64: MateAnalyticsEventPropertyType {}

extension Bool: MateAnalyticsEventPropertyType {}

extension Int: MateAnalyticsEventPropertyType {}


// MARK: - Close Account
//
extension MateAnalyticsEvent {
    /// The source that presents the Jetpack install screen.
    enum CloseAccountSource: String {
        case settings
        case emptyStores = "empty_stores"
    }

    /// Tracked when the user taps to close their WordPress.com account.
    static func closeAccountTapped(source: CloseAccountSource) -> MateAnalyticsEvent {
        MateAnalyticsEvent(name: .closeAccountTapped, properties: ["source": source.rawValue])
    }

    /// Tracked when the WordPress.com account closure succeeds.
    static func closeAccountSuccess() -> MateAnalyticsEvent {
        MateAnalyticsEvent(name: .closeAccountSuccess, properties: [:])
    }

    /// Tracked when the WordPress.com account closure fails.
    static func closeAccountFailed(error: Error) -> MateAnalyticsEvent {
        MateAnalyticsEvent(name: .closeAccountFailed, properties: [:], error: error)
    }
}


// MARK: - In-App Purchases
extension MateAnalyticsEvent {
    enum InAppPurchases {
        enum Keys: String {
            case productID = "product_id"
            case source
            case step
            case error
        }

        enum Source: String {
            case banner
        }

        enum Step: String {
            case planDetails = "plan_details"
            case prePurchaseError = "pre_purchase_error"
            case purchaseUpgradeError = "purchase_upgrade_error"
            case processing
            case completed
        }

        static func planUpgradePurchaseButtonTapped(_ productID: String) -> MateAnalyticsEvent {
            MateAnalyticsEvent(name: .planUpgradePurchaseButtonTapped,
                              properties: [Keys.productID.rawValue: productID])
        }

        static func planUpgradeScreenLoaded(source: Source) -> MateAnalyticsEvent {
            MateAnalyticsEvent(name: .planUpgradeScreenLoaded,
                              properties: [Keys.source.rawValue: source.rawValue])
        }

        static func planUpgradeScreenDismissed(step: Step) -> MateAnalyticsEvent {
            MateAnalyticsEvent(name: .planUpgradeScreenDismissed,
                              properties: [Keys.step.rawValue: step.rawValue])
        }

        static func planUpgradePrePurchaseFailed(error: Error) -> MateAnalyticsEvent {
            MateAnalyticsEvent(name: .planUpgradePurchaseFailed,
                              properties: [Keys.error.rawValue: error.localizedDescription],
                              error: error)
        }

        static func planUpgradePurchaseFailed(error: Error) -> MateAnalyticsEvent {
            MateAnalyticsEvent(name: .planUpgradePurchaseFailed,
                              properties: [Keys.error.rawValue: error.localizedDescription],
                              error: error)
        }
    }
}
