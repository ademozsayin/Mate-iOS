//
//  TargetType.swift
//  Network
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Alamofire

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}



/// Represents an HTTP task.
public enum HTTPTask {

    /// A request with no additional data.
    case requestPlain

    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)

}

public protocol TargetType {
    
    var baseURL: String { get }
    var task: HTTPTask { get }
    var headers: [String: String]? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
}
