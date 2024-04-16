//
//  TargetType.swift
//  Git Repositories
//
//  Created by Mohamed Mostafa Fawzi on 7/1/20.
//  Copyright © 2020 Mohamed Mostafa Fawzi. All rights reserved.
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

    /// A requests body set with data.
//    case requestData(Data)

    /// A request body set with `Encodable` type
//    case requestJSONEncodable(Encodable)

    /// A request body set with `Encodable` type and custom encoder
//    case requestCustomJSONEncodable(parameters: [Array<Any>], Encodable, encoder: ArrayEncoding)
//    / A requests body set with encoded parameters.
    ///
//    case requestArrayParameters(parameters: [[String: Any]], encoding: ArrayEncoding)

    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
    
//    case requestArrayParameters(bodyParameters: [JsonParameters],
//                                bodyEncoding: ArrayParameterEncoding)
    /// A requests body set with data, combined with url parameters.
//    case requestCompositeData(bodyData: Data, urlParameters: [String: Any])

    // A requests body set with encoded parameters combined with url parameters.
//    case requestCompositeParameters(bodyParameters: [String: Any], bodyEncoding: ParameterEncoding, urlParameters: [String: Any])

    /// A file upload task.
//    case uploadFile(URL)

    /// A "multipart/form-data" upload task.
//    case uploadMultipart([MultipartFormData])

    /// A "multipart/form-data" upload task  combined with url parameters.
//    case uploadCompositeMultipart([MultipartFormData], urlParameters: [String: Any])

//    /// A file download task to a destination.
//    case downloadDestination(DownloadDestination)
//
//    /// A file download task to a destination with extra parameters using the given encoding.
//    case downloadParameters(parameters: [String: Any], encoding: ParameterEncoding, destination: DownloadDestination)
}

public protocol TargetType {
    
    var baseURL: String { get }
    var task: HTTPTask { get }
    var headers: [String: String]? { get }
    var path: String { get }
    var method: HTTPMethod { get }
    
}
