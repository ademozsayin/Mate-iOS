//
//  ServiceLocator.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Foundation
import CocoaLumberjack
import Storage
import Redux
import Experiments
/// Provides global dependencies.
///
final class ServiceLocator {

    // MARK: - Private properties

    /// StoresManager
    ///
    private static var _stores: StoresManager = DefaultStoresManager(sessionManager: SessionManager.standard)

    /// CoreData Stack
    ///
    private static var _storageManager = CoreDataManager(name: FiableConstants.databaseStackName, crashLogger: crashLogging)

    
    /// Crash Logging Stack
    ///
    private static var _crashLogging: CrashLoggingStack = WooCrashLoggingStack(
        featureFlagService: featureFlagService
    )

    /// FeatureFlagService
    ///
    private static var _featureFlagService: FeatureFlagService = DefaultFeatureFlagService()

    /// WordPressAuthenticator Wrapper
    ///
    private static var _authenticationManager: Authentication = AuthenticationManager()
    
    
    // MARK: - Getters

    /// Provides the access point to the stores.
    /// - Returns: An implementation of the StoresManager protocol. It defaults to DefaultStoresManager
    static var stores: StoresManager {
        return _stores
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
    
    
    /// Provides the access point to the CrashLogger
    /// - Returns: An implementation
    static var crashLogging: CrashLoggingStack {
        return _crashLogging
    }
    
    
    /// Provides the access point to the AuthenticationManager.
    /// - Returns: An implementation of the AuthenticationManager protocol. It defaults to DefaultAuthenticationManager
    static var authenticationManager: Authentication {
        return _authenticationManager
    }

}


private extension ServiceLocator {
    static func isRunningTests() -> Bool {
        return NSClassFromString("XCTestCase") != nil
    }
}
