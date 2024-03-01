//
//  WeatherDetailViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import UIKit
import Networking

/// Protocol for handling detail view controller actions.
protocol DetailViewControllerProtocol: AnyObject {
    /// Sets the detail page with the given city result.
    /// - Parameter city: The city result to be displayed.
    func setDetailPageWith(_ city: CityResult)
}

/// View controller responsible for displaying weather detail.
final class WeatherDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var windLabel: UILabel!
    @IBOutlet private weak var humidityLabel: UILabel!
    
    // MARK: - Properties
    var presenter: DetailPresenterProtocol?
    var city: CityResult?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
}

// MARK: - DetailViewControllerProtocol Conformance
extension WeatherDetailViewController: DetailViewControllerProtocol {
    func setDetailPageWith(_ city: Networking.CityResult) {
        self.city = city
        self.title = city.name ?? "-"
        
        if let humidity = city.main?.humidity {
            humidityLabel.text = "Humidity: \(humidity)"
        } else {
            humidityLabel.text = "-"
        }
        
        if let wind = city.wind?.speed {
            windLabel.text = "Wind: \(wind)"
        } else {
            windLabel.text = "-"
        }
    }
}

