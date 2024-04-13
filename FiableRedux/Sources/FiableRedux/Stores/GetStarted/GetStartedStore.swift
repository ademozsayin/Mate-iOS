//
//  GetStartedStore.swift
//  Redux
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Combine
import Foundation
import MateNetworking
import MateStorage

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
        dispatcher.register(processor: self, for: GetStartedAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? GetStartedAction else {
            assertionFailure("GetStartedAction received an unsupported action")
            return
        }
        
        switch action {
        case .checkEmail(let email, let onCompletion):
            checkEmail(email: email, completion: onCompletion)
        case .getToken(let email, let password, let onCompletion):
            getTokenWith(email: email, password: password, onCompletion: onCompletion)
            
        case .requestMagicLink(email: let email, completion: let completion):
            requestMagicLink(email: email, completion: completion)
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
    
    func getTokenWith(email: String,
                      password: String,
                      onCompletion: @escaping (_ result: Result<OnsaTokenData, Error>) -> Void) {
        remote.getToken(for: email, password: password) { result in
            switch result {
            case .success(let token):
                onCompletion(.success(token))
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }
    
    func requestMagicLink(email: String, completion: @escaping (Result<String, Error>) -> Void) {
        remote.requestAuthLink(email: email, completion: completion)
    }
}


// MARK: - Persistence
//
extension GetStartedStore {

}
