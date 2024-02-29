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
    func configureCollectionView()
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
    @IBOutlet private weak var collectionView: UICollectionView!
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
        configureCollectionView()
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
        view.applyGradient(colours: colors)
        containerView.backgroundColor = .clear
        weatherHeaderView.applyGradient(colours: colors)
        navbarView.applyGradient(colours: colors)
        scrollView.applyGradient(colours: colors)
    }
    
    final func configureCollectionView() {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = collectionFlowLayout
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.register(cellType: WeatherDayCell.self)
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

// MARK: - UICollectionViewDataSource
extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeCell(cellType: WeatherDayCell.self, indexPath: indexPath)
        if let movie = presenter?.weatherDay(index: indexPath.row) {
//            cell.configure(movie: movie)
        }
        return cell
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 80, height: 180)
    }
}
