//
//  SystemStatusStore.swift
//
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation
import MateNetworking
import MateStorage
/// Implements `SystemStatusActions` actions
///
public final class SystemStatusStore: Store {
    private let remote: SystemStatusRemote

    public override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        self.remote = SystemStatusRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: SystemStatusAction.self)
    }

    /// Receives and executes Actions.
    ///
    public override func onAction(_ action: Action) {
        guard let action = action as? SystemStatusAction else {
            assertionFailure("SystemPluginStore receives an unsupported action!")
            return
        }

        switch action {

        case .fetchSystemStatusReport(let onCompletion):
            fetchSystemStatusReport(completionHandler: onCompletion)
        }
    }
}

// MARK: - Network request
//
private extension SystemStatusStore {

    func fetchSystemStatusReport(completionHandler: @escaping (Result<SystemStatus, Error>) -> Void) {
        remote.loadSystemInformation( completion: completionHandler)
    }
}

// MARK: - Storage
//
private extension SystemStatusStore {
    
}
