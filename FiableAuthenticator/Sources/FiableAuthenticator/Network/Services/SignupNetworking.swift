//
//  SignupNetworking.swift
//
//
//  Created by Adem Özsayın on 14.04.2024.
//



import Foundation
import Alamofire

public enum SignupNetworking {
    case signupWithapple(devicename: String, token:String)
}

extension SignupNetworking: TargetType {
    
    public var baseURL: String {
        return "https://fiable.agency/"
//        #if DEBUG
//        return "https://fiable.agency/"
//        #elseif
//        return "https://fiable.agency/"
//        #endif
    }
//   
    public var path: String {
        switch self {
       
        case .signupWithapple:
            return "api/auth/apple"
        }
    }
//    
    public  var method: HTTPMethod {
        switch self {
        case .signupWithapple:
            return .post
        }
    }
//    
    public var task: HTTPTask {
        switch self {
        case .signupWithapple(let device, let _ ):
            return .requestParameters(parameters: ["device_name": "iOS"], encoding: JSONEncoding.default)
            
        }
    }
//    
    public var headers: [String : String]? {
        switch self {
        case .signupWithapple(_ , let token):
            return ["Authorization": "Bearer \(token)" ]
            
        }
    }
}


