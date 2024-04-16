//
//  FiableResponse.swift
//  FiableNetwork
//
//  Created by Adem Özsayın on 1/12/23.
//

import Foundation

protocol FiableDecodable: Decodable & Keyable { }

protocol Keyable {
    static var codingKey: String { get }
}

struct FiableResponse<T>: Decodable where T: FiableDecodable {
    
    var status: Status {
        if result?.resultCode == 0 {
            return .success
        }
        return .failed
    }
    private(set) var statusInt: Int?
    
    
    private var messageString: String?
    var message: String {
        if let messageString = result?.resultMessage {
            return messageString
        } else {
            return "Something went wrong"
        }
    }
    
    private(set) var data: T?
    
    var result:FantazzieResult?
    
    enum CodingKeys: String, CodingKey {
        //        case statusInt = "status"
        //        case messageString = "message"
        case data = "ReturnObject"
        case result = "Result"
        
        
        var stringValue: String {
            switch self {
            case .data: return T.codingKey
            default: return rawValue
            }
        }
        
    }
    
    init() {
        self.statusInt = -1
        self.messageString = "Something went wrong."
        self.data = nil
        //        self.codeInt = -1
    }
    
    enum Status:CaseIterable,Codable {
        case success
        case failed
    }

}


// MARK: - Result
struct FantazzieResult: Decodable {
    var resultCode: Int?
    var resultMessage: String?
    
    enum CodingKeys: String, CodingKey {
        case resultCode = "ResultCode"
        case resultMessage = "ResultMessage"
    }
}
