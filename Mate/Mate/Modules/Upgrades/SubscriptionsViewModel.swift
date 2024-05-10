import Foundation
import UIKit
import FiableRedux
import Combine

/// ViewModel for the Subscriptions View
/// Drives the site's plan subscription
///
final class SubscriptionsViewModel: ObservableObject {

    /// Indicates if the view should show an error notice.
    ///
    var errorNotice: Notice? = nil

    /// Current store plan.
    ///
    private(set) var planName = ""

    /// Current store plan details information.
    ///
    private(set) var planInfo = ""

    /// Current store plan details information.
    ///
    var planDaysLeft: Int?

    /// Current store plan expiration date, formatted as "MMMM d". e.g: "August 11"
    ///
    var formattedPlanExpirationDate: String?

    /// Defines if the view should show the Full Plan features.
    ///
    private(set) var shouldShowFreeTrialFeatures = true

    /// Defines if the view should show the "Manage Your Subscription"  button.
    ///
    @Published private(set) var shouldShowManageSubscriptionButton = false

    /// Indicates if the view should should a redacted state.
    ///
    private(set) var showLoadingIndicator = false

    /// Holds a reference to the free trial features.
    ///
    let freeTrialFeatures = FreeTrialFeatures.features

    /// Observable subscription store.
    ///
    private var subscriptions: Set<AnyCancellable> = []

    /// Stores manager.
    ///
    private let stores: StoresManager

    /// Shared store plan synchronizer.
    ///
    private let storePlanSynchronizer: StorePlanSynchronizing

    /// Retrieves asynchronously all WPCom plans In-App Purchases products.
    ///
    private let inAppPurchasesPlanManager: InAppPurchasesForWPComPlansProtocol

    /// Analytics provider.
    ///
    private let analytics: MateAnalytics

    /// Feature flag service.
    ///
    private let featureFlagService: FeatureFlagService

    init(stores: StoresManager = ServiceLocator.stores,
         storePlanSynchronizer: StorePlanSynchronizing = ServiceLocator.storePlanSynchronizer,
         inAppPurchasesPlanManager: InAppPurchasesForWPComPlansProtocol = InAppPurchasesForWPComPlansManager(),
         analytics: MateAnalytics = ServiceLocator.analytics,
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService) {
        self.stores = stores
        self.storePlanSynchronizer = storePlanSynchronizer
        self.inAppPurchasesPlanManager = inAppPurchasesPlanManager
        self.analytics = analytics
        self.featureFlagService = featureFlagService
        observePlan()
    }

    /// Loads the plan from network.
    ///
    func loadPlan() {
        storePlanSynchronizer.reloadPlan()
    }

    /// Opens the subscriptions management URL
    ///
    func onManageSubscriptionButtonTapped() {
        let url = FiableConstants.URLs.inAppPurchasesAccountSubscriptionsLink.asURL()
        UIApplication.shared.open(url)
    }
}

// MARK: Helpers
private extension SubscriptionsViewModel {
    /// Whether the In-App Purchases subscription management button should be rendered
    ///
    func shouldRenderManageSubscriptionsButton() {
        guard let siteID = storePlanSynchronizer.site else {
            return
        }

        Task { @MainActor in
            if await inAppPurchasesPlanManager.siteHasCurrentInAppPurchases(siteID: 1) {
                self.shouldShowManageSubscriptionButton = true
            }
        }
    }

    /// Observes and reacts to plan changes
    ///
    func observePlan() {
        storePlanSynchronizer.planStatePublisher.sink { [weak self] planState in
            guard let self else { return }
            switch planState {
            case .loading, .notLoaded:
                self.updateLoadingViewProperties()
            case .loaded:
                print("observePlan: planState: \(planState)")
//                self.updateViewProperties(from: plan)
            case .expired:
                self.updateExpiredViewProperties()
            case .failed, .unavailable:
                self.updateFailedViewProperties()
            }
            self.objectWillChange.send()
        }
        .store(in: &subscriptions)
    }

    func updateLoadingViewProperties() {
        planName = ""
        planInfo = ""
        errorNotice = nil
        showLoadingIndicator = true
        shouldShowFreeTrialFeatures = false
    }

    func updateExpiredViewProperties() {
        planName = Localization.genericPlanEndedName
        planInfo = Localization.planEndedInfo
        errorNotice = nil
        showLoadingIndicator = false
        shouldShowFreeTrialFeatures = false
    }

    func updateFailedViewProperties() {
        planName = ""
        planInfo = ""
        errorNotice = createErrorNotice()
        showLoadingIndicator = false
        shouldShowFreeTrialFeatures = false
    }


    /// Creates an error notice that allows to retry fetching a plan.
    ///
    func createErrorNotice() -> Notice {
        .init(title: Localization.fetchErrorNotice, feedbackType: .error, actionTitle: Localization.retry) { [weak self] in
             self?.loadPlan()
        }
    }
}

// MARK: Definitions
private extension SubscriptionsViewModel {
    enum Localization {
        static let trialEnded = NSLocalizedString("Trial ended", comment: "Plan name for an expired free trial")
        static let trialEndedInfo = NSLocalizedString("Your free trial has ended and you have limited access to all the features. " +
                                                      "Subscribe to a Woo Express Plan now.",
                                                      comment: "Info details for an expired free trial")
        static let planEndedInfo = NSLocalizedString("Your subscription has ended and you have limited access to all the features.",
                                                     comment: "Info details for an expired plan")
        static let fetchErrorNotice = NSLocalizedString("There was an error fetching your plan details, please try again later.",
                                                        comment: "Error shown when failing to fetch the plan details in the upgrades view.")
        static let retry = NSLocalizedString("Retry", comment: "Retry button on the error notice for the upgrade view")

        static let genericPlanEndedName = NSLocalizedString(
            "plan ended",
            comment: "Shown with a 'Current:' label, but when we don't know what the plan that ended was")

        static func planEndedName(name: String) -> String {
            let format = NSLocalizedString("%@ ended", comment: "Reads like: eCommerce ended")
            return String.localizedStringWithFormat(format, name)
        }

        static func freeTrialPlanInfo(planDuration: Int, daysLeft: Int) -> String {
            let format = NSLocalizedString("You are in the %1$d-day free trial. The free trial will end in %2$d days. ",
                                           comment: "Reads like: You are in the 14-day free trial. The free trial will end in 5 days. " +
                                           "Upgrade to unlock new features and keep your store running.")
            return String.localizedStringWithFormat(format, planDuration, daysLeft)
        }

        static func planInfo(planName: String, expirationDate: String) -> String {
            let format = NSLocalizedString("You are subscribed to the %1@ plan! You have access to all our features until %2@.",
                                           comment: "Reads like: You are subscribed to the eCommerce plan! " +
                                                    "You have access to all our features until Nov 28, 2023.")
            return String.localizedStringWithFormat(format, planName, expirationDate)
        }
    }
}
