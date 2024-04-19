//
//  SignupService.swift
//  
//
//  Created by Adem Özsayın on 14.04.2024.
//

import Foundation

// MARK: - Protocols
public protocol SignupAPIProtocol {
    func createOnsaUserWithApple(devicename: String,
                                 token:String,
                                 completionHandler: @escaping (Result<BaseResponse<SignInWithApplePayload>, NSError>) -> Void)

}

public class SignupServiceAPI: BaseAPI<SignupNetworking>, SignupAPIProtocol {
   
    public override init() {}
    
    public func createOnsaUserWithApple(devicename: String,
                                        token:String,
                                        completionHandler: @escaping (Result<BaseResponse<SignInWithApplePayload>, NSError>) -> Void) {
        self.fetchData(target: .signupWithapple(
            devicename: devicename,
            token:token
        ), responseClass: SignInWithApplePayload.self) { result in
            completionHandler(result)
        }
    }
}


// MARK: - Errors
//
enum SignupError: Error {
    case unknown
}
