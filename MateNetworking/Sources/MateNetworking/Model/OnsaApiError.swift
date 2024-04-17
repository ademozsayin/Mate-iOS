//
//  OnsaApiError.swift
//  Networking
//
//  Created by Adem Özsayın on 1.04.2024.
//


import Foundation
import CodeGen

/// Fiable.agency Request Error
///
public enum OnsaApiError: Error, Decodable, Equatable, GeneratedFakeable {

    /// Non explicit reason
    ///
    case empty

    /// Missing Token!
    ///
    case unauthorized

    /// We're not properly authenticated
    ///
    case invalidToken

    /// Remote Request Failed
    ///
    case requestFailed

    /// No route was found matching the URL and request method
    ///
    case noRestRoute

    /// Unknown: Represents an unmapped remote error. Capisce?
    ///
    case unknown(code: String, message: String?)

    /// The requested resourced does not exist remotely
    case resourceDoesNotExist

    /// Decodable Initializer.
    ///
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let error = try container.decode(String.self, forKey: .error)
        let message = try container.decodeIfPresent(String.self, forKey: .message)

        switch error {
        case Constants.invalidToken:
            self = .invalidToken
        case Constants.requestFailed:
            self = .requestFailed
        
        case Constants.unauthorized:
            self = .unauthorized
        case Constants.noRestRoute:
            self = .noRestRoute
       
        case Constants.restTermInvalid where message == ErrorMessages.resourceDoesNotExist:
            self = .resourceDoesNotExist

        default:
            self = .unknown(code: error, message: message)
        }
    }


    /// Constants for Possible Error Identifiers
    ///
    private enum Constants {
        static let unauthorized     = "unauthorized"
        static let invalidBlog      = "invalid_blog"
        static let invalidToken     = "invalid_token"
        static let requestFailed    = "http_request_failed"
        static let noRestRoute      = "rest_no_route"
        static let restTermInvalid  = "woocommerce_rest_term_invalid"
        static let unknownToken     = "unknown_token"
    }

    /// Coding Keys
    ///
    private enum CodingKeys: String, CodingKey {
        case error
        case message
    }

    /// Possible Error Messages
    ///
    private enum ErrorMessages {
        static let statsModuleDisabled = "This blog does not have the Stats module enabled"
        static let noStatsPermission = "user cannot view stats"
        static let resourceDoesNotExist = "Resource does not exist."
        static let jetpackNotConnected = "This blog does not have Jetpack connected"
    }
}


// MARK: - CustomStringConvertible Conformance
//
extension OnsaApiError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .empty:
            return NSLocalizedString("Api Response Empty", comment: "Fiable.agency Error thrown when the response body is empty")
        case .invalidToken:
            return NSLocalizedString("Api Token Invalid", comment: "Fiable.agency Invalid Token")
        case .requestFailed:
            return NSLocalizedString("Api Request Failed", comment: "Fiable.agency Request Failure")
        case .unauthorized:
            return NSLocalizedString("Api Missing Token", comment: "Fiable.agency Missing Token")
        case .noRestRoute:
            return NSLocalizedString("Api Invalid REST Route", comment: "Fiable.agency error thrown when the the request REST API url is invalid.")
    
        case .resourceDoesNotExist:
            return NSLocalizedString("Api Resource does not exist", comment: "Fiable.agency error thrown when a requested resource does not exist remotely.")

        case .unknown(let code, let message):
            let theMessage = message ?? String()
            let messageFormat = NSLocalizedString(
                "Onsa Api Error Error: [%1$@] %2$@",
                comment: "Laravel 11 Api (unmapped!) error. Parameters: %1$@ - code, %2$@ - message"
            )
            return String.localizedStringWithFormat(messageFormat, code, theMessage)
        }
    }
}


// MARK: - Equatable Conformance
//
public func ==(lhs: OnsaApiError, rhs: OnsaApiError) -> Bool {
    switch (lhs, rhs) {
    case (.requestFailed, .requestFailed),
        (.unauthorized, .unauthorized),
        (.noRestRoute, .noRestRoute):
        return true
    case let (.unknown(codeLHS, _), .unknown(codeRHS, _)):
        return codeLHS == codeRHS
    default:
        return false
    }
}
