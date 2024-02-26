//
//  LoginRequest.swift
//  FiableNetwork
//
//  Created by Adem Özsayın on 1/12/23.
//

import Foundation
import Alamofire

public struct WeatherRequest: Decodable {
    
    public let latitude:String
    public let longitude:String
    
    public init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
