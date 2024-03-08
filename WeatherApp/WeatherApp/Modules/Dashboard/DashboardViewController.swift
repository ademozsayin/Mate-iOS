//
//  DashboardViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import UIKit
import Networking
import CoreLocation
import Combine
import Components


// MARK: - DashboardViewControllerProtocol
/// Protocol defining the interactions handled by the DashboardViewController.
protocol DashboardViewControllerProtocol: AnyObject {
    /// Displays the weather information on the dashboard.
    ///
    /// - Parameter weatherInfo: The weather information to display.
    func displayWeatherInfo(_ weatherInfo: WeatherResponse)
    
    /// Shows the last updated weather information.
    ///
    /// - Parameter info: The last updated weather information.
    func showLastUpdatedWeather(info: UserLocationResult?)
    
    /// Shows a loading indicator.
    func showLoading()
    
    /// Hides the loading indicator.
    func hideLoading()
    
    /// Shows an error related to location access.
    ///
    /// - Parameter error: The error related to location access.
    func showLocationError(error: Error)
    
    /// Configures the collection view for displaying weather forecast.
    func configureCollectionView()
    
    /// Reloads data in the collection view.
    func reloadData()
    
    /// Shows an alert with the given message.
    ///
    /// - Parameter message: The message to display in the alert.
    func showAlert(message:String)
    
    /// Sets up the search bar functionality.
    func setSearchBar()
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
    @IBOutlet private weak var searchButton: UIButton!
    
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
        setSearchBar()
        presenter?.viewDidLoad()
    }
}

// MARK: - DashboardViewControllerProtocol Conformance
extension DashboardViewController: DashboardViewControllerProtocol {
    func setSearchBar() {
        searchButton.publisher(for: .touchUpInside)
            .sink { [weak self] _ in
                self?.presenter?.didSearchTapped()
            }
            .store(in: &cancellables)
    }
    
    func showAlert(message: String) {
        showAlert(title: "Error", message: message)
    }
    
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
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(cellType: WeatherDayCell.self)
    }
    
    final func reloadData() {
        collectionView.reloadData()
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
        reloadData()
        guard let weatherInfo else { return }
        displayWeatherInfo(weatherInfo)
    }
}

// MARK: - UICollectionViewDataSource
extension DashboardViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter?.numberOfDays ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
     
        let cell = collectionView.dequeCell(cellType: WeatherDayCell.self, indexPath: indexPath)
        if let list = presenter?.weatherDay(index: indexPath.row) {
            cell.configureWith(list)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(width: 80, height: 180)
    }
}
