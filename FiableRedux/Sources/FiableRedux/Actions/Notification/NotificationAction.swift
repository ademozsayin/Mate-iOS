//
//  NotificationAction.swift
//
//
//  Created by Adem Özsayın on 16.04.2024.
//

import Foundation
import MateNetworking


// MARK: - NotificationAction: Defines all of the Actions supported by the NotificationStore.
//
public enum NotificationAction: Action {

    /// Registers a device for Push Notifications Delivery.
    ///
    case registerDevice(device: APNSDevice,
                        userId:Int,
                        applicationId: String,
                        applicationVersion: String,
                        onCompletion: (MateDevice?, Error?) -> Void)

    /// Unregisters a device for Push Notifications Delivery.
    ///
    case unregisterDevice(deviceId: String, onCompletion: (Error?) -> Void)

    /// Synchronizes the full Notifications collection.
    ///
    case synchronizeNotifications(onCompletion: (Error?) -> Void)

    /// Synchronizes a specified Notification.
    ///
    case synchronizeNotification(noteID: Int64, onCompletion: (Note?, Error?) -> Void)

    /// Updates the WordPress.com Last Seen field.
    ///
    case updateLastSeen(timestamp: String, onCompletion: (Error?) -> Void)

    /// Updates a given Notification's read flag.
    ///
    case updateReadStatus(noteID: Int64, read: Bool, onCompletion: (Error?) -> Void)

    /// Updates, in batch, the Notification's read flag.
    ///
    case updateMultipleReadStatus(noteIDs: [Int64], read: Bool, onCompletion: (Error?) -> Void)
    case updateLocalDeletedStatus(noteID: Int64, deleteInProgress: Bool, onCompletion: (Error?) -> Void)
}
