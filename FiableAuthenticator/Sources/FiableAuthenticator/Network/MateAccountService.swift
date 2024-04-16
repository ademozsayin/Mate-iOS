//
//  MateAccountService.swift
//
//
//  Created by Adem Özsayın on 12.04.2024.
//

import Foundation
import FiableKit
import MateNetworking
import FiableRedux

// MARK: - MateAccountService
//
public class MateAccountService {

    public enum Flow {
        case login
        case register
    }
    /// Makes the intializer public for external access.
    public init() {}

    /// Requests a Mate Api Authentication Link to be sent to the specified email address.
    ///
    /// - Parameters:
    ///   - email: The email address to which the authentication link will be sent.
    ///   - completion: A closure that receives a `Result` indicating success or failure.
    public func requestAuthenticationLink(for email: String, flow:Flow,  completion: @escaping (Result<String, Error>) -> Void) {
        
        var url:URL?
        
        switch flow {
        case .login:
            url = URL(string: "https://fiable.agency/api/generate-magic-link")
        case .register:
            url = URL(string: "https://fiable.agency/api/generate-magic-link-for-signup")
        }
        
        guard let url else {
            completion(.failure(NSError(domain: "com.example", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        // Prepare the request body
        let requestBody: [String: Any] = ["email": email]
        
        // Create the HTTP request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Check for valid response
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NSError(domain: "com.example", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"])))
                return
            }
            
            // Check for data
            guard let data = data else {
                completion(.failure(NSError(domain: "com.example", code: 500, userInfo: [NSLocalizedDescriptionKey: "Empty response data"])))
                return
            }
            
            // Parse the response
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let message = json?["message"] as? String {
                    completion(.success(message))
                } else {
                    completion(.failure(NSError(domain: "com.example", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid response format"])))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func createOnsaUserWithApple(token: String, success: @escaping (SignInWithApplePayload) -> Void, failure: @escaping (Error) -> Void) {
        // Prepare the request URL
        guard let url = URL(string: "https://fiable.agency/api/auth/apple") else {
            failure(NetworkError.invalidURL)
            return
        }
        
        // Prepare the request body
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let requestBody: [String: Any] = [
            "device_name": "Your Device Name",
        ]
        // Add the token as a Bearer token in the header
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        guard let requestBodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            failure(NetworkError.invalidRequestBody)
            return
        }
        request.httpBody = requestBodyData
        
        // Set up the URLSession data task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           
            NetworkLogger.log(request:request)
            NetworkLogger.log(response: response as? HTTPURLResponse, data: data, error: error)

            // Check for network errors
            if let error = error {
                failure(error)
                return
            }
            
            // Check for HTTP status code
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                
                failure(NetworkError.invalidResponse)
                return
            }
            
            NetworkLogger.log(response: httpResponse, data: data, error: error)
            
            // Parse the response data
            guard let responseData = data else {
                failure(NetworkError.noData)
                return
            }
            
            // Decode the response JSON
            do {
                let decoder = JSONDecoder()
                let signInWithApplePayload = try decoder.decode(SignInWithApplePayload.self, from: responseData)
                success(signInWithApplePayload)
            } catch {
                failure(error)
            }
        }
        
        // Start the URLSession data task
        task.resume()
    }


    /// Returns the current FiableAuthenticatorConfiguration Instance.
    ///
    private var configuration: FiableAuthenticatorConfiguration {
        return FiableAuthenticator.shared.configuration
    }
}

// MARK: - Nested Types
//
extension MateAccountService {

    enum ServiceError: Error {
        case unknown
    }
}

// Define a custom error type for network errors
enum NetworkError: Error {
    case invalidURL
    case invalidRequestBody
    case invalidResponse
    case noData
}
