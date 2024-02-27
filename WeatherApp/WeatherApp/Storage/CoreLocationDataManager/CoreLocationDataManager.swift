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
        // Assuming you have an instance of NSManagedObject named locationObject
        if let jsonString = locationObject.prettyJSONString() {
            DDLogInfo(jsonString)
        }
        #endif
        
        do {
            try managedContext.save()
            DDLogInfo("🟢 Saved to storage")
        } catch let error as NSError {
            fatalError("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchLastLocation() -> UserLocationResult? {
        // Fetch user location from Core Data
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: userLocationEntity)
        fetchRequest.fetchLimit = 1
        do {
            if let userLocations = try managedContext.fetch(fetchRequest) as? [UserLocationResult],
                let userLocation = userLocations.first {
                return userLocation
            }
        } catch let error as NSError {
            DDLogError("⛔️ Could not fetch. \(error), \(error.userInfo)")
        }
        
        return nil
    }

}
