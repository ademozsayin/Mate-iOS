//
//  AccountStore.swift
//  Redux
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Combine
import Foundation
import MateNetworking
import MateStorage

// MARK: - AccountStore
//
public class AccountStore: Store {
    private let remote: AccountRemoteProtocol

    /// Shared private StorageType for use during synchronizeSites and synchronizeSitePlan processes
    ///
    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.writerDerivedStorage
    }()

    public convenience override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        let remote = AccountRemote(network: network)
        self.init(dispatcher: dispatcher, storageManager: storageManager, network: network, remote: remote)
    }

    init(dispatcher: Dispatcher,
         storageManager: StorageManagerType,
         network: Network,
         remote: AccountRemoteProtocol) {
        self.remote = remote
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    public override func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: AccountAction.self)
    }

    /// Receives and executes Actions.
    override public func onAction(_ action: Action) {
        guard let action = action as? AccountAction else {
            assertionFailure("AccountStore received an unsupported action")
            return
        }
        switch action {
     
        case .synchronizeAccount(let onCompletion):
            synchronizeAccount(onCompletion: onCompletion)
        case .synchronizeAccountSettings(let userID, let onCompletion):
            print("")
//            synchronizeAccountSettings(userID: userID, onCompletion: onCompletion)
        }
    }
}


// MARK: - Services!
//
private extension AccountStore {
    /// Synchronizes the WordPress.com account associated with the Network's Auth Token.
    ///
    func synchronizeAccount(onCompletion: @escaping (Result<Account, Error>) -> Void) {
        remote.loadAccount { [weak self] result in
            if case let .success(account) = result {
                self?.upsertStoredAccount(readOnlyAccount: account)
            }

            onCompletion(result)
        }
    }

}

// MARK: - Persistence
//
extension AccountStore {
    
    /// Updates (OR Inserts) the specified ReadOnly Account Entity into the Storage Layer.
    ///
    func upsertStoredAccount(readOnlyAccount: MateNetworking.Account) {
        assert(Thread.isMainThread)
        
        let storage = storageManager.viewStorage
        let storageAccount = storage.loadAccount(
            userID: readOnlyAccount.userID
        ) ?? storage.insertNewObject(ofType: MateStorage.Account.self)
        
        storageAccount.update(with: readOnlyAccount)
                storage.saveIfNeeded()
    }
}
