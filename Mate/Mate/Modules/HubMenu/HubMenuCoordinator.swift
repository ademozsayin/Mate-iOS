import Combine
import Foundation
import UIKit

import FiableRedux
/// Coordinator for the HubMenu tab.
///
final class HubMenuCoordinator: Coordinator {
    let navigationController: UINavigationController
    var hubMenuController: HubMenuViewController?

//    private let pushNotificationsManager: PushNotesManager
    private let storesManager: StoresManager
    private let noticePresenter: NoticePresenter
  

    private var notificationsSubscription: AnyCancellable?

    private let willPresentReviewDetailsFromPushNotification: () async -> Void


    init(navigationController: UINavigationController,
//         pushNotificationsManager: PushNotesManager = ServiceLocator.pushNotesManager,
         storesManager: StoresManager = ServiceLocator.stores,
         noticePresenter: NoticePresenter = ServiceLocator.noticePresenter,
         willPresentReviewDetailsFromPushNotification: @escaping () async -> Void) {

//        self.pushNotificationsManager = pushNotificationsManager
        self.storesManager = storesManager
        self.noticePresenter = noticePresenter
        self.willPresentReviewDetailsFromPushNotification = willPresentReviewDetailsFromPushNotification
        self.navigationController = navigationController
    }

    convenience init(navigationController: UINavigationController,
                     willPresentReviewDetailsFromPushNotification: @escaping () async -> Void) {
        let storesManager = ServiceLocator.stores
        self.init(navigationController: navigationController,
                  storesManager: storesManager,
                  willPresentReviewDetailsFromPushNotification: willPresentReviewDetailsFromPushNotification)
    }

    deinit {
        notificationsSubscription?.cancel()
    }

    func start() {
        // No-op: please call `activate(siteID:)` instead when the menu tab is configured.
    }

    /// Replaces `start()` because the menu tab's navigation stack could be updated multiple times when site ID changes.
    func activate(siteID: Int64 = 1) {
        hubMenuController = HubMenuViewController(
            navigationController: navigationController
//            tapToPayBadgePromotionChecker: tapToPayBadgePromotionChecker
        )
        if let hubMenuController = hubMenuController {
            navigationController.viewControllers = [hubMenuController]
        }

//        if notificationsSubscription == nil {
//            notificationsSubscription = Publishers
//                .Merge(pushNotificationsManager.inactiveNotifications, pushNotificationsManager.foregroundNotificationsToView)
//                .sink { [weak self] in
//                    self?.handleNotification($0)
//                }
//        }
    }

    private func handleNotification(_ notification: PushNotification) {
//        guard notification.kind == .comment else {
//            return
//        }
    }

//    private func pushReviewDetailsViewController(using parcel: ProductReviewFromNoteParcel) {
//        hubMenuController?.pushReviewDetailsViewController(using: parcel)
//    }
}

// MARK: - Deeplinks
extension HubMenuCoordinator: DeepLinkNavigator {
    func navigate(to destination: any DeepLinkDestinationProtocol) {
        guard let hubMenuController = hubMenuController else {
            return
        }
        hubMenuController.navigate(to: destination)
    }
}

// MARK: - Constants
private extension HubMenuCoordinator {
    enum Constants {
        // Used to delay a second navigation after the previous one is called,
        // to ensure that the first transition is finished. Without this delay
        // the second one might not happen.
        static let screenTransitionsDelay = 0.3
    }
}
// MARK: - Public Utils

extension HubMenuCoordinator {
    enum Localization {
        static let failedToRetrieveReviewNotificationDetails =
            NSLocalizedString("Failed to retrieve the review notification details.",
                              comment: "An error message shown when failing to retrieve information to present a view for a review push notification.")
    }
}
