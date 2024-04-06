//
//  PushNotification.swift
//  Mate
//
//  Created by Adem Özsayın on 22.03.2024.
//


import Foundation
//import struct Redux.Note

/// Emitted by `PushNotificationsManager` when a remote notification is received while
/// the app is active.
///
struct PushNotification {
    /// The `note_id` value received from the Remote Notification's `userInfo`.
    ///
    let noteID: Int
    /// The `blog` value received from the Remote Notification's `userInfo`.
    ///
    let siteID: Int
    /// The `type` value received from the Remote Notification's `userInfo`.
    ///
//    let kind: Note.Kind
    /// The `alert.title` value received from the Remote Notification's `userInfo`.
    ///
    let title: String
    /// The `alert.subtitle` value received from the Remote Notification's `userInfo`.
    ///
    let subtitle: String?
    /// The `alert.message` value received from the Remote Notification's `userInfo`.
    ///
    let message: String?
}
