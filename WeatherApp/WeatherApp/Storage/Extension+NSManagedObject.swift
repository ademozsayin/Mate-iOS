//
//  Extension+NSManagedObject.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 27.02.2024.
//

import Foundation
import CoreData

extension NSManagedObject {
    func prettyJSONString() -> String? {
        do {
            // Convert NSManagedObject to dictionary
            let dictionary = self.dictionaryWithValues(forKeys: self.entity.attributesByName.keys.map({ $0 }))
            
            // Convert dictionary to JSON data
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            
            // Convert JSON data to pretty-printed string
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            } else {
                print("Failed to convert JSON data to string")
                return nil
            }
        } catch {
            print("Error: \(error.localizedDescription)")
            return nil
        }
    }
}
