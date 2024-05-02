//
//  GooglePlace+CoreDataProperties.swift
//
//
//  Created by Adem Özsayın on 29.04.2024.
//

import Foundation
import CoreData


extension GooglePlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GooglePlace> {
        return NSFetchRequest<GooglePlace>(entityName: "GooglePlace")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String
    @NSManaged public var rating: NSNumber?
    @NSManaged public var latitude: NSNumber?
    @NSManaged public var longitude: NSNumber?
    @NSManaged public var vicinity: String?
    @NSManaged public var event_category_id: NSNumber?
    @NSManaged public var place_id: String?

    

}
