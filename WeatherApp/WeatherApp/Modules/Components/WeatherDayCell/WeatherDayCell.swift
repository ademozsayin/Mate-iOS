//
//  WeatherDayCell.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 29.02.2024.
//

import UIKit
import Networking

// MARK: - WeatherDayCell
final class WeatherDayCell: UICollectionViewCell {

    // MARK: - IBOutlets
    @IBOutlet private weak var containerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
}

// MARK: - Configure
extension WeatherDayCell {
    final func configureWith(_ list: List) {
        print(list.weather?.first?.main ?? "")
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
}
