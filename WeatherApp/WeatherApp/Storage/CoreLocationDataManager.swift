//
//  CoreLocationDataManager.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 27.02.2024.
//

import CoreData
import CoreLocation

/// Protocol defining methods for managing location data.
protocol LocationDataManager {
    /// Saves a CLLocation object representing a location into persistent storage.
    ///
    /// - Parameter location: The CLLocation object to be saved.
    func saveLocation(_ location: CLLocation)
    
    /// Fetches the last saved location from persistent storage.
    ///
    /// - Returns: The last saved CLLocation object, if available; otherwise, nil.
    func fetchLastLocation() -> CLLocation?
}

/// A concrete implementation of LocationDataManager using Core Data to persist location data.
class CoreLocationDataManager: LocationDataManager {
    /// The persistent container used for managing the Core Data stack.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourDataModelName")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func saveLocation(_ location: CLLocation) {
        let managedContext = persistentContainer.viewContext
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Location", in: managedContext) else {
            fatalError("Could not find entity description")
        }
        
        let locationObject = NSManagedObject(entity: entityDescription, insertInto: managedContext)
        locationObject.setValue(location.coordinate.latitude, forKey: "latitude")
        locationObject.setValue(location.coordinate.longitude, forKey: "longitude")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            fatalError("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchLastLocation() -> CLLocation? {
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            if let locationObject = result.first as? NSManagedObject,
               let latitude = locationObject.value(forKey: "latitude") as? CLLocationDegrees,
               let longitude = locationObject.value(forKey: "longitude") as? CLLocationDegrees {
                return CLLocation(latitude: latitude, longitude: longitude)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
}
