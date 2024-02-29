//
//  WeatherError.swift
//  Networking
//
//  Created by Adem Özsayın on 29.02.2024.
//

import Foundation

public struct WeatherError:Codable, Error {
    public let code:Int?
    public let message:String?
    
    public enum GenericErrorCodingKeys: String, CodingKey {
        case code = "code"
        case message = "message"
    }
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: GenericErrorCodingKeys.self)
        code = (try? keyedContainer.decode(Int.self, forKey: GenericErrorCodingKeys.code))
        message = (try? keyedContainer.decode(String.self, forKey: GenericErrorCodingKeys.message))
    }
    
    public init(code: Int?, message: String?) {
        self.code = code
        self.message = message
    }
}
