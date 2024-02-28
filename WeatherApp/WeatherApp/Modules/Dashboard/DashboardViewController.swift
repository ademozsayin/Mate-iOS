//
//  DashboardViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import UIKit
import Components
import Networking
import CoreLocation
import Combine

/// Protocol defining the interactions handled by the DashboardViewController.
protocol DashboardViewControllerProtocol: AnyObject {
    func displayWeatherInfo(_ weatherInfo: WeatherResponse)
    func showLastUpdatedWeather(info: UserLocationResult?)
}

/// Class responsible for presenting the dashboard view.
final class DashboardViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var weatherHeaderView: WeatherHeaderView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var temperatureButton: UIButton!
    // MARK: - Properties
    
    
    // MARK: - Data
    private var cancellables = Set<AnyCancellable>()
    private var userLocationResult: UserLocationResult? {
        didSet {
            updateUserLocationLabel()
        }
    }
    private var weatherInfo: WeatherResponse?
    var presenter: DashboardPresenter?

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackgroundView()
        setupButtonTapHandling()
        presenter?.viewDidLoad()
    }
    
    // MARK: - Private Methods
    
    private func configureBackgroundView() {
        view.backgroundColor = .opaqueSeparator
        scrollView.roundCorners([.topLeft, .topRight], radius: 24)
    }

    private func updateUserLocationLabel() {
        guard let  userLocationResult else { return }
        locationLabel.text = userLocationResult.name
        dateLabel.text = userLocationResult.date?.relativelyFormattedUpdateString
        
    }
}

// MARK: - DashboardViewControllerProtocol Conformance

extension DashboardViewController: DashboardViewControllerProtocol {
   final func showLastUpdatedWeather(info: UserLocationResult?) {
        userLocationResult = info
    }
    
    final func displayWeatherInfo(_ weatherInfo: WeatherResponse) {
        self.weatherInfo = weatherInfo
        locationLabel.text = weatherInfo.name
        dateLabel.text = "Updating"
        weatherHeaderView.configureWith(weatherInfo)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateUserLocationLabel()
        }
    }
}

// MARK: - LoadingShowable Conformance

extension DashboardViewController: LoadingShowable {
    func showLoading() {
        // Show loading indicator
    }
    
    func hideLoading() {
        // Hide loading indicator
    }
}

private extension DashboardViewController {
    final func setupButtonTapHandling() {
        temperatureButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.presentTemperatureUnitSelection()
            }
            .store(in: &cancellables)
    }
    
    final func presentTemperatureUnitSelection() {
        let alertController = UIAlertController(title: "Select Temperature Unit", message: nil, preferredStyle: .actionSheet)
        
        let celsiusAction = UIAlertAction(title: "Celsius", style: .default) { _ in
            UserDefaults.standard.set(TemperatureUnit.celsius.rawValue, forKey: "TemperatureUnit")
            self.reloadView()
        }
        alertController.addAction(celsiusAction)
        
        let fahrenheitAction = UIAlertAction(title: "Fahrenheit", style: .default) { _ in
            UserDefaults.standard.set(TemperatureUnit.fahrenheit.rawValue, forKey: "TemperatureUnit")
            self.reloadView()
        }
        alertController.addAction(fahrenheitAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        // For iPad support
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = temperatureButton
            popoverController.sourceRect = temperatureButton.bounds
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    final func reloadView() {
        guard let weatherInfo else { return }
        displayWeatherInfo(weatherInfo)
    }
}
