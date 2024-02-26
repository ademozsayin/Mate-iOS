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
    
    func noInternetConnection() {}
}
