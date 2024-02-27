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

protocol DashboardViewControllerProtocol: AnyObject {
    func setTitle(_ title: String)
    func displayWeatherInfo(_ weatherInfo: WeatherResponse)
}

final class DashboardViewController: BaseViewController {
   
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    var presenter: DashboardPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presenter?.viewDidLoad()
    }
}

extension DashboardViewController: DashboardViewControllerProtocol {
    func displayWeatherInfo(_ weatherInfo: WeatherResponse) {
        // Update UI with weather information
        locationLabel.text = weatherInfo.name ?? "Unknown"
    }
    
    func setTitle(_ title: String) {
        self.title = title
        let nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.black
        nav?.tintColor = UIColor.orange
        nav?.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.orange]
    }
}

extension DashboardViewController:LoadingShowable {
    func showLoading() {
        DDLogInfo(#function)
    }
    
    func hideLoading() {
        DDLogInfo(#function)
    }
    
}
