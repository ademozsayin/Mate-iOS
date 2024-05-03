//
//  ServiceLocator.swift
//  Mate
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Foundation
import CocoaLumberjack
import MateStorage
import FiableRedux
////import FiableExperiments
/// Provides global dependencies.
///
final class ServiceLocator {

    // MARK: - Private properties

    /// WooAnalytics Wrapper
//    private static var _analytics: Analytics = OnsaAnalytics(analyticsProvider: TracksProvider())
    /// Analytics instance
    private static var _analytics: MateAnalytics = MateAnalytics(provider: FirebaseAnalyticsProvider())

    /// StoresManager
    ///
    private static var _stores: StoresManager = DefaultStoresManager(sessionManager: SessionManager.standard)

    /// CoreData Stack
    ///
    private static var _storageManager = CoreDataManager(name: FiableConstants.databaseStackName)

    /// Push Notifications Manager
    ///
    private static var _pushNotesManager: PushNotesManager = PushNotificationsManager()
    
    /// In-App Notifications Presenter
    ///
    private static var _noticePresenter: NoticePresenter = DefaultNoticePresenter()
    
    /// FeatureFlagService
    ///
    private static var _featureFlagService: FeatureFlagService = DefaultFeatureFlagService()

    /// Authenticator Wrapper
    ///
    private static var _authenticationManager: Authentication = AuthenticationManager()
    
    /// Observer for network connectivity
    ///
    private static var _connectivityObserver: ConnectivityObserver = DefaultConnectivityObserver()
    
    
    /// Cocoalumberjack DDLog
    ///
    private static var _fileLogger: Logs = DDFileLogger()
    
    // MARK: - Getters

    /// Provides the access point to the analytics.
    /// - Returns: An implementation of the Analytics protocol. It defaults to WooAnalytics
    static var analytics: MateAnalytics {
        return _analytics
    }

    
    /// Provides the access point to the stores.
    /// - Returns: An implementation of the StoresManager protocol. It defaults to DefaultStoresManager
    static var stores: StoresManager {
        return _stores
    }
    
    /// Provides the access point to the PushNotesManager.
    /// - Returns: An implementation of the PushNotesManager protocol. It defaults to PushNotificationsManager
    static var pushNotesManager: PushNotesManager {
        return _pushNotesManager
    }
    
    /// Provides the access point to the NoticePresenter.
    /// - Returns: An implementation of the NoticePresenter protocol. It defaults to DefaultNoticePresenter
    static var noticePresenter: NoticePresenter {
        return _noticePresenter
    }
    
    /// Provides the access point to the feature flag service.
    /// - Returns: An implementation of the FeatureFlagService protocol. It defaults to DefaultFeatureFlagService
    static var featureFlagService: FeatureFlagService {
        return _featureFlagService
    }
    
    /// Provides the access point to the StorageManager.
    /// - Returns: An instance of CoreDataManager. Notice how we break the pattern we
    /// use in all other properties provided by the ServiceLocator. Mocked implementations
    /// of the CoreDataManager should be subclasses
    static var storageManager: CoreDataManager {
        return _storageManager
    }
    
    
    /// Provides the access point to the AuthenticationManager.
    /// - Returns: An implementation of the AuthenticationManager protocol. It defaults to DefaultAuthenticationManager
    static var authenticationManager: Authentication {
        return _authenticationManager
    }
    
    /// Provides access point to the ConnectivityObserver.
    /// - Returns: An implementation of the ConnectivityObserver protocol.
    static var connectivityObserver: ConnectivityObserver {
        _connectivityObserver
    }
    
    /// Provides the access point to the FileLogger.
    /// - Returns: An implementation of the Logs protocol. It defaults to DDFileLogger
    static var fileLogger: Logs {
        return _fileLogger
    }

    /// Provides the last known `KeyboardState`.
    ///
    /// Because `static let` is lazy, this should be accessed when the app is started
    /// (i.e. AppDelegate) for it to accurately provide the last known state.
    ///
    static let keyboardStateProvider: KeyboardStateProviding = KeyboardStateProvider()

}


private extension ServiceLocator {
    static func isRunningTests() -> Bool {
        return NSClassFromString("XCTestCase") != nil
    }
}
