//
//  LoginRequest.swift
//  FiableNetwork
//
//  Created by Adem Özsayın on 1/12/23.
//

import Foundation
import Alamofire

public struct WeatherRequest: Decodable {
    
    public let latitude:Double
    public let longitude:Double
    
    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

