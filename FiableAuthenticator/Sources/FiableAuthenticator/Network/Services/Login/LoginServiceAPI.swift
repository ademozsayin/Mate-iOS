//
//  LoginServiceAPI.swift
//  
//
//  Created by Adem Özsayın on 18.04.2024.
//

import Foundation
import struct MateNetworking.OnsaTokenData
import enum MateNetworking.OnsaApiError

// MARK: - Protocols
public protocol LoginServiceAPIProtocol {
    func login(email: String,
               password:String,
               completionHandler: @escaping (Result<BaseResponse<OnsaTokenData>, NSError>) -> Void
    )

}

final class LoginServiceAPI: BaseAPI<Loginetworking>, LoginServiceAPIProtocol {
   
    public override init() {}
    
    public func login(
        email: String,
        password: String,
        completionHandler: @escaping (Result<BaseResponse<MateNetworking.OnsaTokenData>, NSError>) -> Void
    ) {
        self.fetchData(target: .login(email: email, password: password), responseClass: OnsaTokenData.self) { result in
            completionHandler(result)
        }
    }
}
