//
//  UIImage+DownloadIcon.swift
//  Components
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit

/**
 Extension providing functionality related to UIImage objects.
 */
extension UIImage {
    
    /**
     Downloads an image from the web with the given suffix.
     
     - Parameters:
        - suffix: The suffix used to construct the image URL.
        - completion: A closure to be executed upon completion of the download, providing a result that contains either the downloaded image or an error.
     */
    public static func downloadImage(forSuffix suffix: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
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
