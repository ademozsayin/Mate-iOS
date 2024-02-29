//
//  WeatherDayCell.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit
import Networking
import Components

// MARK: - WeatherDayCell
final class WeatherDayCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var temperature: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
}

// MARK: - Configure
extension WeatherDayCell {
    final func configureWith(_ list: List) {
        print(list.weather?.first?.main ?? "")
        timeLabel.text = list.getTimeFromDtTxt()
        configureTemperature(list)
        configureIcon(list.weather?.first?.icon)
    }
}


// MARK: - Setup
private extension WeatherDayCell {
    final func setupView() {
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        containerView.layer.cornerRadius = 16
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOpacity = 0.4
        containerView.layer.shadowOffset = CGSize(width: 2, height: 2)
        containerView.layer.shadowRadius = 4
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
                    self.icon.image = image
                }
            case .failure(let error):
                print("Error downloading image: \(error)")
            }
        }
    }
    
    /**
     Configures the temperature label with the provided weather data.
     
     - Parameter weather: The weather response object containing the temperature data.
     */
    final func configureTemperature(_ list: List) {
        temperature.text = list.main?.temperatureString(unit: TemperatureUnit.currentUnit)
    }
}


