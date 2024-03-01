//
//  DetailPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

/// Protocol for the detail presenter.
protocol DetailPresenterProtocol: AnyObject {
    /// Called when the view has loaded.
    func viewDidLoad()
}

/// Presenter for the weather detail.
final class DetailPresenter: DetailPresenterProtocol {
    
    // MARK: - Properties
    unowned var view: DetailViewControllerProtocol?
    let router: WeatherDetailRouter!
    let interactor: DetailInteractorProtocol!
    private var city: CityResult?
    
    // MARK: - Initialization
    init(
        view: DetailViewControllerProtocol,
        router: WeatherDetailRouter,
        interactor: DetailInteractorProtocol,
        city: CityResult?
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.city = city
    }
   
    // MARK: - DetailPresenterProtocol
    func viewDidLoad() {
        guard let city = city else { return }
        fetchCityDetailOutput(result: city)
    }
}

// MARK: - DetailInteractorOutputProtocol Conformance
extension DetailPresenter: DetailInteractorOutputProtocol {
    func fetchCityDetailOutput(result: CityResult) {
        self.city = result
        view?.setDetailPageWith(result)
    }
}
