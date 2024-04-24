//
//  SupportRemote.swift
//
//
//  Created by Adem Özsayın on 24.04.2024.
//

import Foundation
import struct Alamofire.JSONEncoding
import struct Alamofire.URLEncoding
import protocol Alamofire.ParameterEncoding


public protocol SupportRemoteProtocol {
    
    func createTicket(form_id: String, subject: String, description: String) async throws -> SupportTicketResponse
}

///
public class SupportRemote: Remote, SupportRemoteProtocol {
   
    public func createTicket(form_id: String, subject: String, description: String) async throws -> SupportTicketResponse {
        let path = "\(Path.createTicket)"
        
        let parameters: [String: Any] = [
            "form_id": form_id,
            "subject": subject,
            "description": description
        ]
        let request = OnsaApiRequest( method: .post, path: path, parameters: parameters)

        return try await enqueue(request)
    }
}


/// Contains necessary data for handling the remote response from creating a cart.
public struct SupportTicketResponse: Decodable {
    public let success: Bool?
    public let message: String
    
    private enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}


// MARK: - Constants
//
private extension SupportRemote {
    enum Path {
        static let createTicket = "tickets"
    }
}
