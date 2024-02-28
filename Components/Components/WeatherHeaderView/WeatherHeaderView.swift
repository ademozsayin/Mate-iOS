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
    
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}

// MARK: - Configuration
public extension WeatherHeaderView {
    final func configureWith(_ weather: WeatherResponse) {
        
    }
}
