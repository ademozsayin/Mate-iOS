//
//  StoresManager.swift
//  Redux
//
//  Created by Adem Özsayın on 11.03.2024.
//

import Combine
import Foundation

/// Abstracts the Stores coordination
///
public protocol StoresManager {

    /// Forwards the Action to the current State.
    ///
    func dispatch(_ action: Action)

    /// Forwards the Actions to the current State.
    ///
    func dispatch(_ actions: [Action])

    /// Prepares for changing the selected store and remains Authenticated.
    ///
    func removeDefaultStore()

    /// Switches the internal state to Authenticated.
//    ///
    @discardableResult
    func authenticate(credentials: Credentials) -> StoresManager

    /// Switches the state to a Deauthenticated one.
    ///
    @discardableResult
    func deauthenticate() -> StoresManager

    /// Synchronizes all of the Session's Entities.
    ///
    @discardableResult
    func synchronizeEntities(onCompletion: (() -> Void)?) -> StoresManager

    /// Indicates if the StoresManager is currently authenticated, or not.
    ///
    var isAuthenticated: Bool { get }

    /// Indicates if the StoresManager is currently authenticated with site credentials only.
    ///
    var isAuthenticatedWithoutWPCom: Bool { get }

    /// Publishes signal that indicates if the user is currently logged in with credentials.
    ///
    var isLoggedInPublisher: AnyPublisher<Bool, Never> { get }

    /// SessionManagerProtocol: Persistent Storage for Session-Y Properties.
    /// This property is thread safe
    var sessionManager: SessionManagerProtocol { get }

    /// Deauthenticates upon receiving `ApplicationPasswordsGenerationFailed` notification
    ///
    func listenToApplicationPasswordGenerationFailureNotification()

    /// De-authenticates upon receiving `RemoteDidReceiveInvalidTokenError` notification
    ///
    func listenToWPCOMInvalidWPCOMTokenNotification()
}
