//
//  File.swift
//  
//
//  Created by Adem Özsayın on 14.04.2024.
//

import Foundation
//import WordPressKit

/// SignupService: Responsible for creating a new WPCom user and blog.
///
class SignupService: SocialUserCreating {
    func createWPComUserWithGoogle(
        token: String,
        success: @escaping (Bool, String, String) -> Void,
        failure: @escaping (any Error) -> Void)
    {
        
    }
    
    func createOnsaUserWithApple(
        token: String,
        devicename:String,
        success: @escaping (
            _ payload: BaseResponse<SignInWithApplePayload>?
        ) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        SignupServiceAPI().createOnsaUserWithApple(devicename: devicename, token:token) { result in
            switch result {
            case .success(let data):
                success(data)
            case .failure(let err):
                failure(err)
            }
        }
    }
}

// MARK: - Private
//
private extension SignupService {

    var configuration: FiableAuthenticatorConfiguration {
        return FiableAuthenticator.shared.configuration
    }

    struct ResponseKeys {
        static let bearerToken = "bearer_token"
        static let username = "username"
        static let createdAccount = "created_account"
    }

    struct ErrorKeys {
        static let errorCode = "WordPressComRestApiErrorCodeKey"
        static let existingNonSocialUser = "user_exists"
        static let twoFactorEnabled = "2FA_enabled"
    }
}
