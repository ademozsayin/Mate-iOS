//
//  WeatherDetailViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import UIKit
import Networking

protocol DetailViewControllerProtocol: AnyObject {
    func setDetailPageWith(_ city: CityResult)
}

final class WeatherDetailViewController: UIViewController {

    var presenter: DetailPresenterProtocol?
    var city: CityResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }

}

extension WeatherDetailViewController: DetailViewControllerProtocol {
    
    final func setDetailPageWith(_ city: Networking.CityResult) {
        self.city = city
    }
}
