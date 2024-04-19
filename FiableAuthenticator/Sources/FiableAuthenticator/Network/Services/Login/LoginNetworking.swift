//
//  LoginNetworking.swift
//
//
//  Created by Adem Özsayın on 18.04.2024.
//

import Foundation
import Alamofire
import MateNetworking

public enum Loginetworking {
    case login(email: String, password:String)
}

extension Loginetworking: TargetType {
    
    public var baseURL: String {
        return Settings.onsaApiBaseURL
    }
   
    public var path: String {
        switch self {
       
        case .login:
            return "api/auth/login"
        }
    }
    
    public  var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }
    
    public var task: HTTPTask {
        switch self {
        case .login(let email, let password ):
            return .requestParameters(
                parameters: ["email": email, "password": password], encoding: JSONEncoding.default
            )
            
        }
    }
   
    public var headers: [String : String]? {
        switch self {
        case .login:
            return nil
            
        }
    }
}


