//
//  MateAnalyticsService.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import Foundation

protocol MateAnalyticsService {
    func logEvent(_ eventName: String, parameters: [String: Any])
    func logEvent(_ eventName: String, parameters: [String: Any]? )
    func logEvent(_ eventName: String, parameters: [AnyHashable : Any]? )
}
