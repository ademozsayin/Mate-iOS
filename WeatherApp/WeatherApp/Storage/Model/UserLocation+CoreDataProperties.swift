//
//  Account+CoreDataProperties.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 27.02.2024.
//

import Foundation
import CoreData

extension UserLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserLocation> {
        return NSFetchRequest<UserLocation>(entityName: userLocationEntity)
    }
    // Core Data properties
    @NSManaged public var name: String?
    @NSManaged public var degree: String?
    @NSManaged public var country: String?
    @NSManaged public var longitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var weatherID: Int
    @NSManaged public var weatherMain: String?
    @NSManaged public var weatherDescription: String?
    @NSManaged public var weatherIcon: String?
    @NSManaged public var date: Date?
    

}
