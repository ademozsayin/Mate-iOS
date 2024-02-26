//
//  WeatherAPI.swift
//  Network
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import Alamofire

public protocol WeatherProtocol {

}

public class WeatherAPI: BaseAPI<WeatherNetworking>, WeatherProtocol {
    
    public override init() {
      
    }
}

