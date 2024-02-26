//
//  NetworkLogger.swift
//  Network
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Alamofire

public class NetworkLogger {
    public static func log(request: URLRequest) {
        
        #if DEBUG
            print("\n - - - - - - - - - - OUTGOING REQUEST - - - - - - - - - - \n")
            defer { print("\n - - - - - - - - - -  OUTGOING REQUEST END - - - - - - - - - - \n") }
        #endif
        
        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)
        
        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"
        
        var logOutput = """
                        \(urlAsString) \n\n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }
        #if DEBUG
            print(logOutput)
        #endif
        
    }
    
    public static func log(response: URLResponse) {}
    
    
    public static func log(response: AFDataResponse<Any>) {
    #if DEBUG
        print("\n - - - - - - - - - - RESPONSE INCOMING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }
    #endif
        guard let jsonResponse = try? response.result.get() else {
            print("jsonResponse error")
           
            return
        }
        print(jsonResponse)
    }
    
    public static func log(response: HTTPURLResponse?, data: Data?, error: Error?) {
       print("\n - - - - - - - - - - INCOMING RESPONSE- - - - - - - - - - \n")
       defer { print("\n - - - - - - - - - - INCOMING RESPONSE END - - - - - - - - - - \n") }
       let urlString = response?.url?.absoluteString
       let components = NSURLComponents(string: urlString ?? "")
       let path = "\(components?.path ?? "")"
       let query = "\(components?.query ?? "")"
       var output = ""
       if let urlString = urlString {
          output += "\(urlString)"
          output += "\n\n"
       }
       if let statusCode =  response?.statusCode {
          output += "HTTP \(statusCode) \(path)?\(query)\n"
       }
       if let host = components?.host {
          output += "Host: \(host)\n"
       }
       for (key, value) in response?.allHeaderFields ?? [:] {
          output += "\(key): \(value)\n"
       }
       if let body = data {
          output += "\n\(String(data: body, encoding: .utf8) ?? "")\n"
       }
       if error != nil {
          output += "\nError: \(error!.localizedDescription)\n"
       }
       print(output)
        
    }

}

