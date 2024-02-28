//
//  Sample.swift
//  Components
//
//  Created by Adem Özsayın on 28.02.2024.
//

import UIKit
import Networking

// MARK: - WeatherHeaderView
final public class WeatherHeaderView: UIView, NibOwnerLoadable {
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var weatherStatusLabel: UILabel!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var weatherIcon: UIImageView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherDetailLabel: UILabel!
    @IBOutlet private weak var minMaxLabel: UILabel!
    

    // MARK: - Init
    
    /**
     Initializes the weather header view from a storyboard or nib.
     
     - Parameter aDecoder: An NSCoder instance used to decode the view.
     */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}

// MARK: - Configuration
public extension WeatherHeaderView {
    
    /**
     Configures the weather header view with the provided weather data.
     
     - Parameter weather: The weather response object containing the data to display.
     */
    final func configureWith(_ weather: WeatherResponse) {
        locationLabel.text = weather.name
        dateLabel.text = Date().asWeatherDate()
        weatherStatusLabel.text = weather.weather?.first?.main ?? "-"
        weatherDetailLabel.text = weather.weather?.first?.description ?? "-"
        minMaxLabel.text = weather.main?.minMaxTemperatureString(unit: TemperatureUnit.currentUnit)
        configureTemperature(weather)
        configureIcon(weather.weather?.first?.icon)
    }
}

private extension WeatherHeaderView {
    
    /**
     Configures the temperature label with the provided weather data.
     
     - Parameter weather: The weather response object containing the temperature data.
     */
    final func configureTemperature(_ weather: WeatherResponse) {
        temperatureLabel.text = weather.main?.temperatureString(unit: TemperatureUnit.currentUnit)
    }
    
    /**
     Configures the weather icon with the provided icon name.
     
     - Parameter icon: The name of the weather icon.
     */
    final func configureIcon(_ icon: String?) {
        guard let icon else { return }
        UIImage.downloadImage(forSuffix: icon) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.weatherIcon.image = image
                }
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    }
}
