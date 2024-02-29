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


// MARK: - Weather
public struct Weather: Codable {
    public let id: Int
    public let main, icon: String?
    public var description:WeatherType?
    
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

public enum WeatherType: String, Codable {
    case clearSky = "clear sky"
    case fewClouds = "few clouds"
    case scatteredClouds = "scattered clouds"
    case brokenClouds = "broken clouds"
    case showerRain = "shower rain"
    case rain = "rain"
    case thunderstorm = "thunderstorm"
    case snow = "snow"
    case mist = "mist"
    case over = "overcast clouds"
    case light = "light rain"
    case moderate = "moderate rain"
//    case lightSnow = "light snow"
    case unknown
    
    // Define gradient colors for each weather type
    public var gradientColors: [UIColor] {
        switch self {
        case .clearSky:
            return [UIColor.blue, UIColor.cyan]
        case .fewClouds:
            return [UIColor.lightGray, UIColor.darkGray]
        case .scatteredClouds:
            return [UIColor.gray, UIColor.white]
        case .brokenClouds:
            return [UIColor.darkGray, UIColor.lightGray]
        case .showerRain:
            return [UIColor.gray, UIColor.blue]
        case .rain, .light, .moderate:
            return [UIColor.darkGray, UIColor.gray]
        case .thunderstorm:
            return [UIColor.black, UIColor.darkGray]
        case .snow:
            return [UIColor.white, UIColor.lightGray]
        case .mist, .over:
            return [UIColor.lightGray, UIColor.systemPink]
        case .unknown:
            return [UIColor.lightGray, UIColor.systemPink]

        }
    }
    
    // Custom initializer to handle unknown values
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = WeatherType(rawValue: rawValue) ?? .unknown
        }

    
    // TODO: Make text colors according to type 
}
