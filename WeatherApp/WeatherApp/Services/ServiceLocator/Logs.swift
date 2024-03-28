//
//  Logs.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 22.03.2024.
//

import Foundation
import CocoaLumberjack

/// Abstracts the Login engine.
///
protocol Logs {
    var logFileManager: DDLogFileManager { get }
    var rollingFrequency: TimeInterval { get set }
}

extension DDFileLogger: Logs { }
