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

// MARK: - DashboardViewControllerProtocol
protocol DashboardViewControllerProtocol: AnyObject {
    func displayWeatherInfo(_ weatherInfo: WeatherResponse)
    func showLastUpdatedWeather(info: UserLocationResult?)
    func showLoading()
    func hideLoading()
    func showLocationError(error: Error)
}

/// Class responsible for presenting the dashboard view.
final class DashboardViewController: BaseViewController {
    
    // MARK: - Outlets
    @IBOutlet private weak var weatherHeaderView: WeatherHeaderView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var temperatureButton: UIButton!
    @IBOutlet private weak var containerView: UIView!
    
    @IBOutlet private weak var navbarView: UIView!
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
}

// MARK: - DashboardViewControllerProtocol Conformance
extension DashboardViewController: DashboardViewControllerProtocol {
    func showLocationError(error: Error) {
        let alertController = UIAlertController(title: "Location Access Required", message: "Please enable location access in settings.", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { 
            _ in
            // Open app settings
            self.redirectToLocationSettings()
        }
        alertController.addAction(settingsAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func redirectToLocationSettings() {
       guard let appSettings = URL(string: UIApplication.openSettingsURLString) else { return }
       if UIApplication.shared.canOpenURL(appSettings) {
           UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
       }
   }
    
    final func showLastUpdatedWeather(info: UserLocationResult?) {
        userLocationResult = info
    }
    
    final func displayWeatherInfo(_ weatherInfo: WeatherResponse) {
        self.weatherInfo = weatherInfo
        if let colors = weatherInfo.weather?.first?.description?.gradientColors {
            applyGradient(colors: colors)
        }
        locationLabel.text = weatherInfo.name
        dateLabel.text = "Updating"
        updateUserLocationLabel()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.weatherHeaderView.configureWith(weatherInfo)
        }
    }
    
    final func applyGradient(colors:  [UIColor] ) {
        containerView.backgroundColor = .clear
        weatherHeaderView.applyGradient(colours: colors)
        navbarView.applyGradient(colours: colors)
        scrollView.applyGradient(colours: colors)
    }
}

// MARK: - LoadingShowable Conformance
extension DashboardViewController: LoadingShowable {
    func showLoading() {
        print("show loading")
        LoadingView.shared.startLoading()
    }
    
    func hideLoading() {
        // Hide loading indicator
        LoadingView.shared.hideLoading()
    }
}

// MARK: - Configuration
private extension DashboardViewController {
    // MARK: - Private Methods
    final func configureBackgroundView() {
        view.backgroundColor = .opaqueSeparator
    }
    
    final func updateUserLocationLabel() {
        guard let  userLocationResult else { return }
        locationLabel.text = userLocationResult.name
        dateLabel.text = userLocationResult.date?.relativelyFormattedUpdateString
    }
    
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
