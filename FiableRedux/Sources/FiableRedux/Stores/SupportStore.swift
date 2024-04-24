//
//  SupportStore.swift
//  
//
//  Created by Adem Özsayın on 24.04.2024.
//
import MateNetworking
import MateStorage

import Foundation

final public class SupportStore: Store {
    private let remote: SupportRemoteProtocol

    /// Shared private StorageType for use during synchronizeSites and synchronizeSitePlan processes
    ///
    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.writerDerivedStorage
    }()

    public convenience override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        let remote = SupportRemote(network: network)
        self.init(dispatcher: dispatcher, storageManager: storageManager, network: network, remote: remote)
    }

    init(dispatcher: Dispatcher,
         storageManager: StorageManagerType,
         network: Network,
         remote: SupportRemoteProtocol) {
        self.remote = remote
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    public override func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: SupportAction.self)
    }

    /// Receives and executes Actions.
    override public func onAction(_ action: Action) {
        guard let action = action as? SupportAction else {
            assertionFailure("EventAction received an unsupported action")
            return
        }
        switch action {
        case .createTicket(let form_id, let subject, let description, let onCompletion):
            createTicket(form_id: form_id, subject: subject, description: description, completion: onCompletion)
        }
    }
}


// MARK: - Services!
//
private extension SupportStore {
        
    func createTicket(
        form_id: String,
        subject: String,
        description: String,
        completion: @escaping (Result<SupportTicketResponse, OnsaApiError>) -> Void) {
            
        Task { @MainActor in
            do {
                let response = try await remote.createTicket(form_id: form_id, subject: subject, description: description)
                completion(.success(response))
            } catch let error {
                let onsaApiError: OnsaApiError
                switch error {
                case OnsaApiError.invalidToken:
                   onsaApiError = .invalidToken
                case OnsaApiError.requestFailed:
                   onsaApiError = .requestFailed
                default:
                    onsaApiError = .unknown(error: nil, message: error.localizedDescription)
                }
               // Pass the error to the completion handler
                completion(.failure(onsaApiError))
            }
        }
    }
}


