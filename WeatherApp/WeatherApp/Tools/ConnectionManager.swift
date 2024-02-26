//
//  ConnectionManager.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

/**
 A singleton class responsible for managing network connection status.

 Use this class to monitor network reachability and perform actions based on the network status.

 - Note: This class relies on the `Reachability` framework for determining network reachability.

 ### Example:

 ```swift
 ConnectionManager.isReachable { connectionManager in
     print("Network is reachable")
 }
 */
import Foundation

class ConnectionManager: NSObject {

    /// The shared instance of the `ConnectionManager` class.
    static let sharedInstance: ConnectionManager = { return ConnectionManager() }()

    /// The reachability instance used to monitor network status.
    var reachability: Reachability!

    
    override init() {
        super.init()

        reachability = try? Reachability()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name:  .reachabilityChanged,
            object: reachability
        )
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /**
     Handles the network status change notification.

     - Parameter notification: The notification object containing information about the network status change.
     */
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReachiblityChange"), object: nil)
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    /**
     Stops the reachability notifier.
     */
    static func stopNotifier() -> Void {
        do {
            try (ConnectionManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }

    /**
     Checks if the network is reachable.

     - Parameter completed: A closure to be executed if the network is reachable.
     */
    static func isReachable(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection != .unavailable {
            completed(ConnectionManager.sharedInstance)
        }
    }
    
    /**
     Checks if the network is unreachable.

     - Parameter completed: A closure to be executed if the network is unreachable.
     */
    static func isUnreachable(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection == .unavailable {
            completed(ConnectionManager.sharedInstance)
        }
    }
    
    /**
     Checks if the network is reachable via WWAN (cellular).

     - Parameter completed: A closure to be executed if the network is reachable via WWAN.
     */
    static func isReachableViaWWAN(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection == .cellular {
            completed(ConnectionManager.sharedInstance)
        }
    }

    
    /**
     Checks if the network is reachable via WiFi.

     - Parameter completed: A closure to be executed if the network is reachable via WiFi.
     */
    static func isReachableViaWiFi(completed: @escaping (ConnectionManager) -> Void) {
        if (ConnectionManager.sharedInstance.reachability).connection == .wifi {
            completed(ConnectionManager.sharedInstance)
        }
    }
}
