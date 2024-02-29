//
//  WeatherError.swift
//  Networking
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

public struct WeatherError:Codable, Error {
    public var code:String?
    public var message:String?
    
    public enum GenericErrorCodingKeys: String, CodingKey {
        case code = "cod"
        case message = "message"
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: GenericErrorCodingKeys.self)
        code = (try? keyedContainer.decodeIfPresent(String.self, forKey: GenericErrorCodingKeys.code)) ?? ""
        
        message = (try? keyedContainer.decodeIfPresent(String.self, forKey: GenericErrorCodingKeys.message))
    }
    
    public init(code: String?, message: String?) {
        self.code = code
        self.message = message
    }
}
