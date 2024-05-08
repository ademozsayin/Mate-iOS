//
//  File.swift
//  
//
//  Created by Adem Özsayın on 8.05.2024.
//

import Foundation
import CoreData


extension UserEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserEvent> {
        return NSFetchRequest<UserEvent>(entityName: "UserEvent")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var category_id: String?
    
    
    @NSManaged public var user_id: String?
    @NSManaged public var event_id: String?
    @NSManaged public var attendance_status: String?
    @NSManaged public var created_at: String?
    @NSManaged public var start_time: String?
    @NSManaged public var google_place_id: String?
    @NSManaged public var address: String?
    @NSManaged public var updated_at: String?
    @NSManaged public var name: String?
    @NSManaged public var max_attendees: String?
    @NSManaged public var joined_attendees: String?

    
}
