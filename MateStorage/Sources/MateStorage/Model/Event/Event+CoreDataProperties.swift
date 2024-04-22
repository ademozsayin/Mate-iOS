//
//  StorageEvent.swift
//
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation
import CoreData


extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?

}
