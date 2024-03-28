//
//  AccountRemote.swift
//  Networking
//
//  Created by Adem Özsayın on 25.03.2024.
//

import Combine
import Foundation

/// Protocol for `AccountRemote` mainly used for mocking.
///
/// The required methods are intentionally incomplete. Feel free to add the other ones.
///
public protocol AccountRemoteProtocol {
  
//    func checkIfEmailIsExist(for email: String) -> AnyPublisher<Result<EmailCheckData, Error>, Never>
    func checkIfEmailIsExist(for email: String, completion: @escaping (Result<EmailCheckData, Error>) -> Void)
}

/// Account: Remote Endpoints
///
public class AccountRemote: Remote, AccountRemoteProtocol {
//    public func checkIfEmailIsExist(for email: String) -> AnyPublisher<Result<EmailCheckData, any Error>, Never> {
//        <#code#>
//    }
    
    

    /// Checks the WooCommerce site settings endpoint to confirm if the WooCommerce plugin is available or not.
    /// We pass an empty `_fields` just to reduce the response payload size, as we don't care about the contents.
    /// The current use case is for a workaround for Jetpack Connection Package sites.
    /// - Parameter siteID: Site for which we will fetch the site settings.
    /// - Returns: A publisher that emits a boolean which indicates if WooCommerce plugin is active.
//    public func checkIfEmailIsExist(for email: String) -> AnyPublisher<Result<EmailCheckData, Error>, Never> {
    public func checkIfEmailIsExist(for email: String, completion: @escaping (Result<EmailCheckData, Error>) -> Void) {

        let parameters = ["email": email]
        let request = FiableRequest(
            method: .post,
            path: Constants.appEmailCheckPath,
            parameters: parameters
        )
        let mapper = EmailAvailabilityMapper()
//        enqueue(request, mapper: mapper)
        enqueue(request, mapper: mapper, completion: completion)
    }
    
}

// MARK: - Constants
//
private extension AccountRemote {
    enum Constants {
        static let appEmailCheckPath: String = "checkIfEmailExist/"
    }

    enum ParameterKey {
        static let name = "name"
    }

    enum Path {
        static let settings = "me/settings"
        static let username = "me/username"
        static let usernameSuggestions = "users/username/suggestions"
        static let accountCreation = "users/new"
        static let closeAccount = "me/account/close"
    }
}

/// Necessary data for account credentials.
public struct CreateAccountResult: Decodable, Equatable {
    public let authToken: String
    public let username: String

    public init(authToken: String, username: String) {
        self.authToken = authToken
        self.username = username
    }

    private enum CodingKeys: String, CodingKey {
        case authToken = "bearer_token"
        case username
    }
}

/// Possible errors from WPCOM account creation.
public enum CreateAccountError: Error, Equatable {
    case emailExists
    case invalidUsername
    case invalidEmail
    case invalidPassword(message: String?)
    case unexpected(error: DotcomError)
    case unknown(error: NSError)

    /// Decodable Initializer.
    ///
    init(dotcomError error: DotcomError) {
        if case let .unknown(code, message) = error {
            switch code {
            case Constants.emailExists:
                self = .emailExists
            case Constants.invalidEmail:
                self = .invalidEmail
            case Constants.invalidPassword:
                self = .invalidPassword(message: message)
            case Constants.invalidUsername, Constants.usernameExists:
                self = .invalidUsername
            default:
                self = .unexpected(error: error)
            }
        } else {
            self = .unexpected(error: error)
        }
    }

    /// Constants for Possible Error Identifiers
    ///
    private enum Constants {
        static let emailExists = "email_exists"
        static let invalidEmail = "email_invalid"
        static let invalidPassword = "password_invalid"
        static let usernameExists = "username_exists"
        static let invalidUsername = "username_invalid"
    }
}
