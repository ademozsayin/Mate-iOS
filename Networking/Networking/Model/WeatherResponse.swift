//
//  WeatherResponse.swift
//  Networking
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import UIKit.UIImage

// MARK: - WeatherResponse
public struct WeatherResponse: Codable {
    public let coord: Coord?
    public let weather: [Weather]?
    public let main: Main?
    public let name: String?
    public let cod: Int?
}

// MARK: - Coord
public struct Coord: Codable {
    public let lon, lat: Double
}

// MARK: - Main
public struct Main: Codable {
    public let temp: Double?
    public let temp_min:Double?
    public let temp_max:Double?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case temp_min
        case temp_max
    }

}

// MARK: - Sys
public struct Sys: Codable {
    public let country: String
}

// MARK: - Weather
public struct Weather: Codable {
    public let id: Int
    public let main, description, icon: String?
    
    public static func downloadImage(forIcon icon: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Construct the image URL with the given icon
        let urlString = "http://openweathermap.org/img/w/\(icon).png"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Download the image data asynchronously
        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: url)
                if let image = UIImage(data: imageData) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "Weather", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
