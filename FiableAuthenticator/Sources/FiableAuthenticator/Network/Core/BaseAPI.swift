//
//  BaseAPI.swift
//  Git Repositories
//
//  Created by Adem Özsayın on 7/1/20.
//  Copyright © 2020 Adem Özsayın. All rights reserved.
//

import Foundation
import Alamofire

public enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

public enum CustomResult<String>{
    case success
    case failure(String)
}

public class BaseAPI<T:TargetType> {
    
    var request: Alamofire.Request?

    public func fetchData<M: Decodable>(target: T,
                                        responseClass: M.Type,
                                        completionHandler:@escaping (Result<BaseResponse<M>, NSError>)-> Void) {

                
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let parameters = buildParams(task: target.task)
        
        let showLogs = showLogs()
        
        AF.request(target.baseURL + target.path,
                        method: method,
                        parameters: parameters.0,
                        encoding: parameters.1,
                        headers: headers
        )
        .responseDecodable(of: BaseResponse<M>.self) { response in
            
            guard let request = response.request else {
                print("no request found")
                print(response)
                return
            }
            
            if showLogs {
                print("Response Duration Target For - \(target)  : \(response.metrics?.taskInterval.duration ?? 0)")
                NetworkLogger.log(request:request)
                NetworkLogger.log(response: response.response, data: response.data, error: response.error)
            }
            //
            guard let statusCode = response.response?.statusCode else {
                
#if DEBUG
                completionHandler(.failure(NSError(domain: response.error?.localizedDescription ?? "", code: 1001, userInfo: [ "error" : "Status Code Error" ])))
                
                
#else
                completionHandler(.failure(NSError(domain: "Something went wrong", code: 1001, userInfo: ["error":"No data"])))
                
#endif
                return
            }
            
            guard let responseData = response.data else {
#if DEBUG
                completionHandler(.failure(NSError(domain: "No data from response", code: statusCode, userInfo: ["error":"No data"])))
                
#else
                completionHandler(.failure(NSError(domain: "Something went wrong", code: statusCode, userInfo: ["error":"No data"])))
                
#endif
                
                return
            }
            do {
                let decoder = JSONDecoder()
                let responseObj = try decoder.decode(BaseResponse<M>.self, from: responseData) //Decode JSON Response Data
                completionHandler(.success(responseObj))
            } catch let DecodingError.dataCorrupted(context) {
                
#if DEBUG
                print(context)
                completionHandler(.failure(NSError(domain: context.debugDescription, code: statusCode, userInfo: ["error":"No data"])))
#else
                completionHandler(.failure(NSError(domain: "Something went wrong", code: statusCode, userInfo: ["error":"No data"])))
#endif
                
            } catch let DecodingError.keyNotFound(key, context) {
                
                
                
#if DEBUG
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                
                let message = "Key '\(key)' not found:"  + context.debugDescription
                
                completionHandler(.failure(NSError(domain: message, code: statusCode, userInfo: ["error":"No data"])))
#else
                completionHandler(.failure(NSError(domain: "Something went wrong", code: statusCode, userInfo: ["error":"No data"])))
#endif
            } catch let DecodingError.valueNotFound(value, context) {
                
                
#if DEBUG
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                
                let message = "Value '\(value)' not found:" + context.debugDescription
                completionHandler(.failure(NSError(domain: message, code: statusCode, userInfo: ["error":"No data"])))
#else
                completionHandler(.failure(NSError(domain: "Something went wrong ", code: statusCode, userInfo: ["error":"No data"])))
#endif
            } catch let DecodingError.typeMismatch(type, context)  {
                
#if DEBUG
                print("Type '\(type)' mismatch:", context.debugDescription)
                print("codingPath:", context.codingPath)
                
                let message = "Type '\(type)' mismatch:" +  context.debugDescription
                completionHandler(.failure(NSError(domain: message, code: statusCode, userInfo: ["error":"No data"])))
#else
                completionHandler(.failure(NSError(domain: "Something went wrong ", code: statusCode, userInfo: ["error":"No data"])))
#endif
                
            } catch {
                print("error: ", error)
#if DEBUG
                completionHandler(.failure(NSError(domain: error.localizedDescription, code: statusCode, userInfo: ["error":"No data"])))
#endif
                completionHandler(.failure(NSError(domain: "Something went wrong ", code: statusCode, userInfo: ["error":"No data"])))
            }
        }
    }
    
    public func buildParams(task: HTTPTask) -> ([String: Any], ParameterEncoding ) {
        switch task {
        case .requestPlain:
            return ([:], URLEncoding.default)
            
        case .requestParameters(parameters: let parameters, encoding: let encoding):
            return (parameters, encoding)
  
        }
    }
    
    public func handleNetworkResponse(_ response: HTTPURLResponse) -> CustomResult<String> {
        switch response.statusCode {
        case 200...299: return .success
        case 401...500: return .failure(NetworkResponse.authenticationError.rawValue)
        case 501...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
    public func showLogs() -> Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
}

