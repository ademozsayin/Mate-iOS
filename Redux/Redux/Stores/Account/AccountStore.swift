//
//  AccountStore.swift
//  Redux
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Combine
import Foundation
import Networking
import Storage

// MARK: - AccountStore
//
public class AccountStore: DeauthenticatedStore {
    private let remote: AccountRemoteProtocol

    
    public init(remote: AccountRemote, dispatcher: Dispatcher) {
        self.remote = remote
        super.init(dispatcher: dispatcher)
    }

    public convenience init(network: Network, dispatcher: Dispatcher) {
        let remote = AccountRemote(network: network)
        self.init(remote: remote, dispatcher: dispatcher)
    }

    public override func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: AccountAction.self)
    }

    
//    public convenience override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
//        let remote = AccountRemote(network: network)
//        self.init(dispatcher: dispatcher, storageManager: storageManager, network: network, remote: remote)
//    }
//
//    init(dispatcher: Dispatcher,
//         storageManager: StorageManagerType,
//         network: Network,
//         remote: AccountRemoteProtocol) {
//        self.remote = remote
//        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
//    }

    /// Registers for supported Actions.
    ///
//    override public func registerSupportedActions(in dispatcher: Dispatcher) {
//        dispatcher.register(processor: self, for: AccountAction.self)
//    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? AccountAction else {
            assertionFailure("AccountStore received an unsupported action")
            return
        }
        
        switch action {
        case .checkEmail(let email, let onCompletion):
            checkEmail(email: email, completion: onCompletion)
        }
    }
}


// MARK: - Services!
//
private extension AccountStore {
    /// Submits the tracks opt-in / opt-out setting to be synced globally.
    ///
//    func checkEmail(email: String, onCompletion:@escaping (Result<Bool, Error>) -> Void) {
//        let data = remote.checkIfEmailIsExist(for: email)
//        onCompletion(data)
//    }
//    
    func checkEmail(email: String, completion: @escaping (Result<EmailCheckData, Error>) -> Void) {
        remote.checkIfEmailIsExist(for: email, completion: completion)
    }
    
}

//private extension AccountStore {
//    func isRemoteFeatureFlagEnabled(_ email: String, completion: @escaping (Bool) -> Void) {
//        Task { @MainActor in
//            do {
//                let featureFlags = try await remote.loadAllFeatureFlags()
//                await MainActor.run {
//                    completion(featureFlags[featureFlag] ?? defaultValue)
//                }
//            } catch {
//                DDLogError("⛔️ FeatureFlagStore: Failed to load feature flags with error: \(error)")
//                await MainActor.run {
//                    completion(defaultValue)
//                }
//            }
//        }
//    }
//}


// MARK: - Persistence
//
extension AccountStore {

}

enum SynchronizeSiteError: Error, Equatable {
    case unknownSite
}
