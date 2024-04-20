//
//  AuthenticatedState.swift
//  Mate
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Foundation
import FiableRedux
import MateNetworking
import MateStorage

// MARK: - AuthenticatedState
//
class AuthenticatedState: StoresManagerState {

    /// Dispatcher: Glues all of the Stores!
    ///
    private let dispatcher = Dispatcher()

    /// Retains all of the active Services
    ///
    private let services: [ActionsProcessor]

    /// NotificationCenter Tokens
    ///
    private var errorObserverToken: NSObjectProtocol?

    /// For tracking events from Networking layer
    ///
//    private let trackEventRequestNotificationHandler: TrackEventRequestNotificationHandler

    /// Designated Initializer
    ///
    init(credentials: Credentials) {
        let storageManager = ServiceLocator.storageManager
        let network = AlamofireNetwork(credentials: credentials)

        
        var services: [ActionsProcessor] = [
            NotificationStore(dispatcher: dispatcher, storageManager: storageManager, network: network),
            EventStore(dispatcher: dispatcher, storageManager: storageManager, network: network)
        ]


        if case .wpcom = credentials {
            services.append(contentsOf: [
                AccountStore(dispatcher: dispatcher, storageManager: storageManager, network: network),
//                WordPressThemeStore(dispatcher: dispatcher, storageManager: storageManager, network: network)
            ])
        } else {
            DDLogInfo("No ONSAAPI auth token found. AccountStore is not initialized.")
        }

        switch credentials {
        case let .wporg(_, _, siteAddress):
            /// Needs Jetpack connection store to handle Jetpack setup for non-Jetpack sites.
            /// `AlamofireNetwork` is used here to handle requests with application password auth.
//            services.append(JetpackConnectionStore(dispatcher: dispatcher, network: network, siteURL: siteAddress))
            print("")

        case .wpcom:
            /// When authenticated with WPCom, the store is used to handle Jetpack setup when a selected site doesn't have Jetpack.
            /// The store will require cookie-nonce auth, which is handled by a `WordPressOrgNetwork`
            /// injected later through the `authenticate` action before any other action is triggered.
//            services.append(JetpackConnectionStore(dispatcher: dispatcher))
            print("")
        }

        self.services = services

//        trackEventRequestNotificationHandler = TrackEventRequestNotificationHandler()

        startListeningToNotifications()
    }

    /// Convenience Initializer
    ///
    convenience init?(sessionManager: SessionManagerProtocol) {
        guard let credentials = sessionManager.defaultCredentials else {
            return nil
        }

        self.init(credentials: credentials)
    }

    /// Executed before the current state is deactivated.
    ///
    func willLeave() {
//        let pushNotesManager = ServiceLocator.pushNotesManager

//        pushNotesManager.unregisterForRemoteNotifications()
//        pushNotesManager.resetBadgeCountForAllStores(onCompletion: {})

        resetServices()
    }

    /// Executed whenever the state is activated.
    ///
    func didEnter() { }


    /// Forwards the received action to the Actions Dispatcher.
    ///
    func onAction(_ action: Action) {
        dispatcher.dispatch(action)
    }
}


// MARK: - Private Methods
//
private extension AuthenticatedState {

    /// Starts listening for Notifications
    ///
    func startListeningToNotifications() {
        let nc = NotificationCenter.default
//        errorObserverToken = nc.addObserver(forName: .RemoteDidReceiveJetpackTimeoutError, object: nil, queue: .main) { [weak self] note in
//            self?.tunnelTimeoutWasReceived(note: note)
//        }
    }

    /// Executed whenever a DotcomError is received (ApplicationLayer). This allows us to have a *main* error handling flow!
    ///
    func tunnelTimeoutWasReceived(note: Notification) {
//        ServiceLocator.analytics.track(.jetpackTunnelTimeout)
    }
}


private extension AuthenticatedState {
    func resetServices() {
//        let resetStoredProviders = AppSettingsAction.resetStoredProviders(onCompletion: nil)
//        let resetOrdersSettings = AppSettingsAction.resetOrdersSettings
//        let resetProductsSettings = AppSettingsAction.resetProductsSettings
//        let resetGeneralStoreSettings = AppSettingsAction.resetGeneralStoreSettings
//        ServiceLocator.stores.dispatch([resetStoredProviders,
//                                        resetOrdersSettings,
//                                        resetProductsSettings,
//                                        resetGeneralStoreSettings])
    }
}
