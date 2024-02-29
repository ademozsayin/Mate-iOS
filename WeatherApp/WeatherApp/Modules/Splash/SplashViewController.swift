//
//  SplashViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import UIKit
import Networking

// MARK: - SplashViewControllerProtocol
protocol SplashViewControllerProtocol: AnyObject {
    func noInternetConnection()
    func isReachable(status:Bool)
}

// MARK: - SplashViewController
final class SplashViewController: BaseViewController {
    
    var presenter: SplashPresenterProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidAppear()
    }
}

// MARK: - SplashViewControllerProtocol
extension SplashViewController: SplashViewControllerProtocol {
    
    final func noInternetConnection() {
        func noInternetConnection() {
            showAlert(title: "Error", message: "No Internet Connection, Please check your connection!")
        }
    }
    
    final func isReachable(status:Bool) {
        status ? print("online") : noInternetConnection()

    }

}
