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

import Foundation
import UIKit
import Components
import Networking
import CoreLocation

/// Protocol defining the interactions handled by the DashboardViewController.
protocol DashboardViewControllerProtocol: AnyObject {
    func displayWeatherInfo(_ weatherInfo: WeatherResponse)
    func showLastUpdatedWeather(info: UserLocationResult?)
}

/// Class responsible for presenting the dashboard view.
final class DashboardViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Properties
    
    private var userLocationResult: UserLocationResult? {
        didSet {
            updateUserLocationLabel()
        }
    }
    
    var presenter: DashboardPresenter?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        view.backgroundColor = .systemBackground
        presenter?.viewDidLoad()
    }
    
    // MARK: - Private Methods
    
    private func configureNavigationBar() {
        guard let navBar = navigationController?.navigationBar else { return }
        navBar.barStyle = .black
        navBar.tintColor = .orange
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
    }
    
    private func updateUserLocationLabel() {
        guard let userLocation = userLocationResult else { return }
        locationLabel.text = userLocation.name
        dateLabel.text = userLocation.date?.relativelyFormattedUpdateString
    }
}

// MARK: - DashboardViewControllerProtocol Conformance

extension DashboardViewController: DashboardViewControllerProtocol {
    func showLastUpdatedWeather(info: UserLocationResult?) {
        userLocationResult = info
    }
    
    func displayWeatherInfo(_ weatherInfo: WeatherResponse) {
        locationLabel.text = weatherInfo.name
        dateLabel.text = "Updating"
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
