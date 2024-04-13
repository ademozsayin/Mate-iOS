//
//  GetStartedAction.swift
//  Redux
//
//  Created by Adem Özsayın on 2.04.2024.
//


import Foundation
import MateNetworking



// MARK: - AccountAction: Defines all of the Actions supported by the AccountStore.
//
public enum GetStartedAction: Action {
    case checkEmail(email: String, onCompletion: (Result<EmailCheckData, Error>) -> Void)
    case getToken(
        email: String,
        password: String,
        onCompletion: (Result<OnsaTokenData, Error>) -> Void)
    
    case requestMagicLink(email:String, completion: (Result<String, Error>) -> Void)


}
