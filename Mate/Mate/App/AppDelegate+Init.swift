//
//  AppDelegate+Init.swift
//  Mate
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import CocoaLumberjack

// MARK: - Initialization Methods
extension AppDelegate {
    
    /// Sets up CocoaLumberjack logging.
    ///
    final func setupCocoaLumberjack() {
        let fileLogger = DDFileLogger()
        fileLogger.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        
        guard let logger = fileLogger as? DDFileLogger else {
            return
        }
        DDLog.add(DDOSLogger.sharedInstance)
        DDLog.add(logger)
        DDLogVerbose("👀 setupCocoaLumberjack...")
        
    }
    
    /// Sets up the current Log Level.
    ///
    final func setupLogLevel(_ level: DDLogLevel) {
//        CocoaLumberjack.log = level
        DDLogVerbose("👀 setupLogLevel to \(level)")
        
    }

    
    func getSQLitePath() -> String? {
#if DEBUG
        // Get the URL for the app's "Documents" directory
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let databaseURL = documentsDirectory.appendingPathComponent("Mate.sqlite")
            return databaseURL.path
        }
        return nil
#endif

    }
    
    ///
   
}
