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
    
    
    public func fetchData<M: Decodable>(target: T,
                                        responseClass: M.Type,
                                        //                                        interceptor: RequestInterceptor? = nil,
                                        completionHandler:@escaping (Result<M, WeatherError>)-> Void) {
        
        let method = Alamofire.HTTPMethod(rawValue: target.method.rawValue)
        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
        let parameters = buildParams(task: target.task)
        
        AF.request(target.baseURL + target.path,
                   method: method,
                   parameters: parameters.0,
                   encoding: parameters.1,
                   headers: headers)
        .responseDecodable(of: M.self) { response in
            
            guard let request = response.request else {
                print("no request found")
                print(response)
                return
            }
            
           
            print("Response Duration Target For - \(target)  : \(response.metrics?.taskInterval.duration ?? 0)")
            NetworkLogger.log(request:request)
            NetworkLogger.log(response: response.response, data: response.data, error: response.error)
            //
            guard let statusCode = response.response?.statusCode,
                  let responseData = response.data else {
                return
            }
   
            do {
                let decoder = JSONDecoder()
                let responseObj = try decoder.decode(M.self, from: responseData) //Decode JSON Response Data
                completionHandler(.success(responseObj))
            } catch let DecodingError.dataCorrupted(context) {
                
                print(context)
                
            } catch let DecodingError.keyNotFound(key, context) {
                
                
#if DEBUG
                print("Key '\(key)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                
                let message = "Key '\(key)' not found:"  + context.debugDescription
                
                completionHandler(.failure(WeatherError(code: "\(statusCode)", message: message)))
#else
                completionHandler(.failure(NSError(domain: "Something went wrong", code: statusCode, userInfo: ["error":"No data"])))
#endif
            } catch let DecodingError.valueNotFound(value, context) {
                
                
#if DEBUG
                print("Value '\(value)' not found:", context.debugDescription)
                print("codingPath:", context.codingPath)
                
                let message = "Value '\(value)' not found:" + context.debugDescription
                completionHandler(.failure(WeatherError(code: "\(statusCode)", message: message)))
#else
                completionHandler(.failure(NSError(domain: "Something went wrong ", code: statusCode, userInfo: ["error":"No data"])))
#endif
            } catch let DecodingError.typeMismatch(type, context)  {

                do {
                    let decoder = JSONDecoder()
                    let responseObj = try decoder.decode(WeatherError.self, from: responseData) //Decode JSON Response Data
                    completionHandler(.failure(WeatherError(code: "\(statusCode)", message: responseObj.message ?? "")))
                } catch  {
                    completionHandler(.failure(WeatherError(code: "\(statusCode)", message: "message")))
                }

            } catch {
                print("error: ", error)
#if DEBUG
                completionHandler(.failure(WeatherError(code: "\(statusCode)", message: error.localizedDescription)))

#endif
                completionHandler(.failure(WeatherError(code: "\(statusCode)", message: error.localizedDescription)))

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
}
