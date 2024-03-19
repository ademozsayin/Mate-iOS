//
//  AuthenticationManager.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 19.03.2024.
//

import Foundation
import KeychainAccess
import Redux
import class Networking.UserAgent
import enum Experiments.ABTest
import struct Networking.Settings
import protocol Experiments.FeatureFlagService
import protocol Storage.StorageManagerType
import protocol Networking.ApplicationPasswordUseCase
import class Networking.DefaultApplicationPasswordUseCase
import protocol Experiments.ABTestVariationProvider
import struct Experiments.CachedABTestVariationProvider

/// Encapsulates all of the interactions with the WordPress Authenticator
///
class AuthenticationManager: Authentication {
    func handleAuthenticationUrl(_ url: URL, options: [UIApplication.OpenURLOptionsKey : Any], rootViewController: UIViewController) -> Bool {
        return true
    }
    
    var displayAuthenticatorIfLoggedOut: (() -> UINavigationController?)?

    /// Keychain access for SIWA auth token
    ///
    private lazy var keychain = Keychain(service: FiableConstants.keychainServiceName)

    /// Apple ID is temporarily stored in memory until we can save it to Keychain when the authentication is complete.
    ///
    private var appleUserID: String?

    /// App settings when the app is in logged out state.
    ///
    private var loggedOutAppSettings: LoggedOutAppSettingsProtocol?

    /// Storage manager to inject to account matcher
    ///
    private let storageManager: StorageManagerType

    private let stores: StoresManager

    private let featureFlagService: FeatureFlagService

    init(stores: StoresManager = ServiceLocator.stores,
         storageManager: StorageManagerType = ServiceLocator.storageManager,
         featureFlagService: FeatureFlagService = ServiceLocator.featureFlagService,
         abTestVariationProvider: ABTestVariationProvider = CachedABTestVariationProvider()) {
        self.stores = stores
        self.storageManager = storageManager
        self.featureFlagService = featureFlagService
    }

    /// Initializes the WordPress Authenticator.
    ///
    func initialize() {
       
    }

    /// Returns the Login Flow view controller.
    ///
    func authenticationUI() -> UIViewController {
//        let loginViewController: UIViewController = {
//            let loginUI = WordPressAuthenticator.loginUI(onLoginButtonTapped: { [weak self] in
//                guard let self = self else { return }
//                // Resets Apple ID at the beginning of the authentication.
//                self.appleUserID = nil
//
//            })
//            guard let loginVC = loginUI else {
//                fatalError("Cannot instantiate login UI from WordPressAuthenticator")
//            }
//            return loginVC
//        }()
//        return loginViewController
        return UIViewController()
    }

    private func isAppLoginUrl(_ url: URL) -> Bool {
        let expectedPrefix = FiableConstants.appLoginURLPrefix
        return url.absoluteString.hasPrefix(expectedPrefix)
    }

    /// Injects `loggedOutAppSettings`
    ///
    func setLoggedOutAppSettings(_ settings: LoggedOutAppSettingsProtocol) {
        loggedOutAppSettings = settings
    }

    
}



// MARK: - ViewModel Factory
extension AuthenticationManager {
    /// This is only exposed for testing.
//    func viewModel(_ error: Error) -> ULErrorViewModel? {
//        let wooAuthError = AuthenticationError.make(with: error)
//
//        switch wooAuthError {
//        case .emailDoesNotMatchWPAccount, .invalidEmailFromWPComLogin, .invalidEmailFromSiteAddressLogin:
//            return NotWPAccountViewModel(error: error)
//        case .notWPSite,
//             .notValidAddress:
//            return NotWPErrorViewModel()
//        case .noSecureConnection:
//            return NoSecureConnectionErrorViewModel()
//        case .unknown, .invalidPasswordFromWPComLogin, .invalidPasswordFromSiteAddressWPComLogin:
//            return nil
//        }
//    }
}

// MARK: - Error handling
private extension AuthenticationManager {

    /// Maps error codes emitted by WPAuthenticator to a domain error object
    enum AuthenticationError: Int, Error {
        case emailDoesNotMatchWPAccount
        case invalidEmailFromSiteAddressLogin
        case invalidEmailFromWPComLogin
        case invalidPasswordFromSiteAddressWPComLogin
        case invalidPasswordFromWPComLogin
        case notWPSite
        case notValidAddress
        case noSecureConnection
        case unknown

//        static func make(with error: Error) -> AuthenticationError {
//            if let error = error as? SignInError {
//                switch error {
//                case .invalidWPComEmail(let source):
//                    switch source {
//                    case .wpCom, .custom:
//                        return .invalidEmailFromWPComLogin
//                    case .wpComSiteAddress:
//                        return .invalidEmailFromSiteAddressLogin
//                    }
//                case .invalidWPComPassword(let source):
//                    switch source {
//                    case .wpCom, .custom:
//                        return .invalidPasswordFromWPComLogin
//                    case .wpComSiteAddress:
//                        return .invalidPasswordFromSiteAddressWPComLogin
//                    }
//                }
//            }
//
//            let error = error as NSError
//
//            switch error.code {
//            case NSURLErrorCannotFindHost,
//                 NSURLErrorCannotConnectToHost:
//                // The site cannot be found. This can mean that the domain is invalid.
//                return .notValidAddress
//            case NSURLErrorSecureConnectionFailed:
//                // The site does not have a valid SSL. It could be that it is only HTTP.
//                return .noSecureConnection
//            default:
//                let restAPIErrorCode = error.userInfo["WordPressComRestApiErrorCodeKey"] as? String
//                if restAPIErrorCode == "unknown_user" {
//                    return .emailDoesNotMatchWPAccount
//                }
//                return .unknown
//            }
//        }
    }

//    func isSupportedError(_ error: Error) -> Bool {
//        let wooAuthError = AuthenticationError.make(with: error)
//        return wooAuthError != .unknown
//    }
}
