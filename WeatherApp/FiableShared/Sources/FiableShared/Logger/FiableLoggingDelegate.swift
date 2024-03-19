//
//  FiableLoggingDelegate.swift
//  
//
//  Created by Adem Özsayın on 19.03.2024.
//

import Foundation

protocol FiableLoggingDelegate: AnyObject {
    func logError(_ str: String)
    func logWarning(_ str: String)
    func logInfo(_ str: String)
    func logDebug(_ str: String)
    func logVerbose(_ str: String)
}
