import Foundation
import UserNotifications
import FiableRedux

/// Handles the scheduling of local notifications with support of remote feature flags.
final class LocalNotificationScheduler {
    private let pushNotesManager: PushNotesManager
    private let stores: StoresManager

    init(pushNotesManager: PushNotesManager,
         stores: StoresManager = ServiceLocator.stores) {
        self.pushNotesManager = pushNotesManager
        self.stores = stores
    }

    /// Schedules a local notification behind an optional remote feature flag.
    /// - Parameters:
    ///   - notification: Local notification to schedule.
    ///   - trigger: When the local notification is scheduled to arrive.
    ///   - remoteFeatureFlag: If non-nil, the local notification is only scheduled when the remote feature flag is enabled (disabled by default).
    ///     If nil, the local notification is always scheduled.
    ///   - shouldSkipIfScheduled: Make sure that no pending notifications have the same identifier
    ///    before scheduling the notification.
    ///
//    @MainActor
//    func schedule(notification: LocalNotification,
//                  trigger: UNNotificationTrigger?,
//                  remoteFeatureFlag: RemoteFeatureFlag?,
//                  shouldSkipIfScheduled: Bool = false) async {
//        if let remoteFeatureFlag, await isRemoteFeatureFlagEnabled(remoteFeatureFlag) == false {
//            return
//        }
//
//        if shouldSkipIfScheduled {
//            await pushNotesManager.requestLocalNotificationIfNeeded(notification, trigger: trigger)
//        } else {
//            await pushNotesManager.requestLocalNotification(notification,
//                                                            trigger: trigger)
//        }
//    }

    /// Cancels a local notification of the given scenario.
    /// - Parameter scenario: The scenario to cancel.
    func cancel(scenario: LocalNotification.Scenario) async {
        await pushNotesManager.cancelLocalNotification(scenarios: [scenario])
    }
}

private extension LocalNotificationScheduler {
//    @MainActor
//    func isRemoteFeatureFlagEnabled(_ remoteFeatureFlag: RemoteFeatureFlag) async -> Bool {
//        await withCheckedContinuation { continuation in
//            stores.dispatch(FeatureFlagAction.isRemoteFeatureFlagEnabled(remoteFeatureFlag, defaultValue: false) { isEnabled in
//                continuation.resume(returning: isEnabled)
//            })
//        }
//    }
}
