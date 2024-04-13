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
  
    func checkIfEmailIsExist(for email: String, completion: @escaping (Result<EmailCheckData, Error>) -> Void)
    func getToken(for email: String,
                  password: String,
                  completion: @escaping (Result<OnsaTokenData, Error>) -> Void)
    func loadAccount(completion: @escaping (Result<Account, Error>) -> Void) 
    func requestAuthLink(email:String, completion: @escaping (Result<String, Error>) -> Void)
    
}

/// Account: Remote Endpoints
///
public class AccountRemote: Remote, AccountRemoteProtocol {
    public func requestAuthLink(email: String, completion: @escaping (Result<String, any Error>) -> Void) {
        let request = OnsaApiRequest(
            method: .post,
            path: Path.magic_link
        )
        
        let mapper = MagicLinkMapper()
        enqueue(request, mapper: mapper, completion: completion)
    }
           
    /// Loads the Account Details associated with the Credential's authToken.
    ///
    public func loadAccount(completion: @escaping (Result<Account, Error>) -> Void) {
    

        let request = OnsaApiRequest(
            method: .get,
            path: Path.me
        )
        
        let mapper = AccountMapper()
        enqueue(request, mapper: mapper, completion: completion)
    }

    
    public func getToken(for email: String, password: String, completion: @escaping (Result<OnsaTokenData, any Error>) -> Void) {
        let parameters = [
            "email": email,
            "password": password
        ]
        
        let request = OnsaApiRequest(
            method: .post,
            path: Path.getToken,
            parameters: parameters
        )
        
        let mapper = TokenMapper()
        enqueue(request, mapper: mapper, completion: completion)
    }
    
    public func checkIfEmailIsExist(for email: String, completion: @escaping (Result<EmailCheckData, Error>) -> Void) {

        let parameters = ["email": email]
        let request = OnsaApiRequest(
            method: .post,
            path: Constants.appEmailCheckPath,
            parameters: parameters
        )
        let mapper = EmailAvailabilityMapper()
        enqueue(request, mapper: mapper, completion: completion)
    }
}

// MARK: - Constants
//
private extension AccountRemote {
    enum Constants {
        static let appEmailCheckPath: String = "user/check-email"
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
        static let getToken = "auth/login"
        static let me = "auth/me"
        static let magic_link = "generate-magic-link"
    }
}

/// Possible errors from WPCOM account creation.
public enum LoginAccountError: Error, Equatable {
    case emailExists
    case invalidUsername
    case invalidEmail
    case invalidPassword(message: String?)
    case unexpected(error: OnsaApiError)
    case unknown(error: NSError)

    /// Decodable Initializer.
    ///
    init(onsaError error: OnsaApiError) {
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
