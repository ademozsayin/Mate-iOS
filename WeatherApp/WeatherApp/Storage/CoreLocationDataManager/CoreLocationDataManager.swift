//
//  CoreLocationDataManager.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 27.02.2024.
//

import CoreData
import CoreLocation

typealias UserLocationEntity = String
let userLocationEntity: UserLocationEntity = "UserLocation"

/// Protocol defining methods for managing location data.
protocol LocationDataManager {
    /// Saves a CLLocation object representing a location into persistent storage.
    ///
    /// - Parameter location: The CLLocation object to be saved.
    func save(_ weather: UserLocation)
    
    /// Fetches the last saved location from persistent storage.
    ///
    /// - Returns: The last saved CLLocation object, if available; otherwise, nil.
    func fetchLastLocation() -> UserLocationResult?
}

/// A concrete implementation of LocationDataManager using Core Data to persist location data.
class CoreLocationDataManager: LocationDataManager {
    
    /// The persistent container used for managing the Core Data stack.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherApp")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func save(_ weather: UserLocation) {
        let managedContext = persistentContainer.viewContext
        
        // Fetch request to check if the location already exists
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: userLocationEntity)
        fetchRequest.predicate = NSPredicate(format: "name == %@", weather.name ?? "Unknown")
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            if let existingLocation = results.first as? NSManagedObject {
                // Update existing location
                existingLocation.setValue(weather.latitude, forKey: "latitude")
                existingLocation.setValue(weather.longitude, forKey: "longitude")
                existingLocation.setValue(weather.degree, forKey: "degree")
                existingLocation.setValue(Date(), forKey: "date")
                
                try managedContext.save()
                DDLogInfo("🟢 Location updated")
                
            #if DEBUG
            // Assuming you have an instance of NSManagedObject named locationObject
                if let jsonString = existingLocation.prettyJSONString() {
                    DDLogInfo(jsonString)
                }
            #endif
                
            } else {
                // Create new location object
                guard let entityDescription = NSEntityDescription.entity(forEntityName: userLocationEntity, in: managedContext) else {
                    fatalError("Could not find entity description")
                }
                let locationObject = NSManagedObject(entity: entityDescription, insertInto: managedContext)
                locationObject.setValue(weather.name, forKey: "name")
                locationObject.setValue(weather.latitude, forKey: "latitude")
                locationObject.setValue(weather.longitude, forKey: "longitude")
                locationObject.setValue(weather.degree, forKey: "degree")
                locationObject.setValue(Date(), forKey: "date")
                                
                #if DEBUG
                    if let jsonString = locationObject.prettyJSONString() {
                        DDLogInfo(jsonString)
                    }
                #endif
                
                try managedContext.save()
                DDLogInfo("🟢 Location saved")
            }
        } catch let error as NSError {
            fatalError("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    
    func fetchLastLocation() -> UserLocation? {
        let managedContext = persistentContainer.viewContext
        
        // Create fetch request to fetch locations ordered by date in descending order
        let fetchRequest: NSFetchRequest<UserLocation> = UserLocation.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        fetchRequest.fetchLimit = 1 // Fetch only the first result
        
        do {
            let locations = try managedContext.fetch(fetchRequest)
            return locations.first // Return the first (most recent) location
        } catch let error as NSError {
            fatalError("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
