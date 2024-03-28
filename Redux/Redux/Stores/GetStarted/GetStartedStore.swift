//
//  GetStartedStore.swift
//  Redux
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Combine
import Foundation
import Networking
import Storage

public class GetStartedStore: DeauthenticatedStore {
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
private extension GetStartedStore {

    func checkEmail(email: String, completion: @escaping (Result<EmailCheckData, Error>) -> Void) {
        
        remote.checkIfEmailIsExist(for: email) { result in
            switch result {
            case .success(let data):
                completion(.success((data)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
}


// MARK: - Persistence
//
extension GetStartedStore {

}
