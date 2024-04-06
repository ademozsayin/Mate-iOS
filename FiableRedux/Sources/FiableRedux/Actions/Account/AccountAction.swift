//
//  AccountAction.swift
//  Redux
//
//  Created by Adem Özsayın on 26.03.2024.
//

import Foundation
import MateNetworking



// MARK: - AccountAction: Defines all of the Actions supported by the AccountStore.
//
public enum AccountAction: Action {

    case synchronizeAccount(onCompletion: (Result<Account, Error>) -> Void)
    case synchronizeAccountSettings(userID: Int64, onCompletion: (Result<AccountSettings, Error>) -> Void)

}
