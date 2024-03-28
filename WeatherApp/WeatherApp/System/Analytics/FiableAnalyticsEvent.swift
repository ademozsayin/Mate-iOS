//
//  FiableAnalyticsEvent.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 20.03.2024.
//

import Foundation


/// This struct represents an analytics event. It is a combination of `WooAnalyticsStat` and
/// its properties.
///
/// This was mostly created to promote static-typing via constructors.
///
/// ## Adding New Events
///
/// 1. Add the event name (`String`) to `WooAnalyticsStat`.
/// 2. Create an `extension` of `WooAnalyticsStat` if necessary for grouping.
/// 3. Add a `static func` constructor.
///
/// Here is an example:
///
/// ~~~
/// extension WooAnalyticsEvent {
///     enum LoginStep: String {
///         case start
///         case success
///     }
///
///     static func login(step: LoginStep) -> WooAnalyticsEvent {
///         let properties = [
///             "step": step.rawValue
///         ]
///
///         return WooAnalyticsEvent(name: "login", properties: properties)
///     }
/// }
/// ~~~
///
/// Examples of tracking calls (in the client App or Pod):
///
/// ~~~
/// Analytics.track(event: .login(step: .start))
/// Analytics.track(event: .loginStart)
/// ~~~
///
public struct FiableAnalyticsEvent {
    init(statName: OnsaAnalyticsStat, properties: [String: FiableAnalyticsEventPropertyType], error: Error? = nil) {
        self.statName = statName
        self.properties = properties
        self.error = error
    }

    let statName: OnsaAnalyticsStat
    let properties: [String: FiableAnalyticsEventPropertyType]
    let error: Error?
}

// MARK: - In-app Feedback and Survey

extension FiableAnalyticsEvent {

    /// The action performed on the In-app Feedback Card.
    public enum AppFeedbackPromptAction: String {
        case shown
        case liked
        case didntLike = "didnt_like"
    }

    /// Where the feedback was shown. This is shared by a couple of events.
    public enum FeedbackContext: String {
        /// Shown in Stats but is for asking general feedback.
        case general
        /// Shown in products banner for general feedback.
        case productsGeneral  = "products_general"
        /// Shown in shipping labels banner for Milestone 3 features.
        case shippingLabelsRelease3 = "shipping_labels_m3"
        /// Shown in beta feature banner for order add-ons.
        case addOnsI1 = "add-ons_i1"
        /// Shown in orders banner for order creation release.
        case orderCreation = "order_creation"
        /// Shown in beta feature banner for coupon management.
        case couponManagement = "coupon_management"
        /// Shown in store setup task list
        case storeSetup = "store_setup"
        /// Tap to Pay on iPhone feedback button shown in the Payments menu after the first payment with TTP
        case tapToPayFirstPaymentPaymentsMenu
        /// Shown in Product details form for a AI generated product
        case productCreationAI = "product_creation_ai"
    }

    /// The action performed on the survey screen.
    public enum SurveyScreenAction: String {
        case opened
        case canceled
        case completed
    }

    /// The action performed on "New Features" banners like in Products.
    public enum FeatureFeedbackBannerAction: String {
        case gaveFeedback = "gave_feedback"
        case dismissed
    }

    /// The action performed on a shipment tracking number like in a shipping label card in order details.
    public enum ShipmentTrackingMenuAction: String {
        case track
        case copy
    }

    /// The result of a shipping labels API GET request.
    public enum ShippingLabelsAPIRequestResult {
        case success
        case failed(error: Error)

        fileprivate var rawValue: String {
            switch self {
            case .success:
                return "success"
            case .failed:
                return "failed"
            }
        }
    }


    static func ordersListLoadError(_ error: Error) -> FiableAnalyticsEvent {
        FiableAnalyticsEvent(statName: .ordersListLoadError, properties: [:], error: error)
    }
}

