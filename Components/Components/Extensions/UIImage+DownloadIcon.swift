//
//  UIImage+DownloadIcon.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit

extension UIImage {
    static func downloadImage(forSuffix suffix: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        // Construct the image URL with the given suffix
        let urlString = "https://openweathermap.org/img/w/\(suffix).png"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "UIImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        // Download the image data asynchronously
        DispatchQueue.global().async {
            do {
                let imageData = try Data(contentsOf: url)
                if let image = UIImage(data: imageData) {
                    completion(.success(image))
                } else {
                    completion(.failure(NSError(domain: "UIImage", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create image from data"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
    }
}
