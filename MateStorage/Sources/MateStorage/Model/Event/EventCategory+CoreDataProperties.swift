//
//  EventCategory.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import CoreData


extension EventCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventCategory> {
        return NSFetchRequest<EventCategory>(entityName: "EventCategory")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
}
