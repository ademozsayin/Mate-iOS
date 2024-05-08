//
//  File.swift
//  
//
//  Created by Adem Özsayın on 8.05.2024.
//

import Foundation
import MateStorage
import MateNetworking

// MARK: - Storage.Account: ReadOnlyConvertible
//
extension StorageUserEvent: ReadOnlyConvertible {
   

    /// Updates the Storage.Account with the a ReadOnly.
    ///
    public func update(with event: FiableRedux.UserEvent) {
        id = Int64(event.id)
        title = event.name
        user_id = event.userID
        event_id = event.pivot?.eventID
        attendance_status = event.pivot?.attendanceStatus
        category_id = event.categoryID
        created_at = event.createdAt ?? ""
        //longiture
        start_time = event.startTime
        google_place_id = event.googlePlaceID
        address = event.address  ?? ""
        updated_at = event.updatedAt  ?? ""
        joined_attendees = event.joinedAttendees
        name = event.name
        max_attendees = event.maxAttendees  
    }

    /// Returns a ReadOnly version of the receiver.
    public func toReadOnly() -> MateNetworking.UserEvent {
        return UserEvent(id: Int(id),
                         name: name ?? "",
                         startTime: start_time ?? "",
                         categoryID: category_id ?? "",
                         createdAt: created_at ?? "",
                         updatedAt: updated_at ?? "",
                         userID: user_id ?? "",
                         address: address ?? "",
                         latitude: "",
                         longitude: "",
                         maxAttendees: max_attendees ?? "",
                         joinedAttendees: joined_attendees ?? "",
                         googlePlaceID: google_place_id ?? "",
                         pivot: Pivot(userID: user_id ?? "",
                                      eventID: event_id ?? "",
                                      attendanceStatus: attendance_status ?? "",
                                      createdAt: created_at ?? "",
                                      updatedAt: updated_at ?? ""),
                         statusKey: nil)
    }
    
}
