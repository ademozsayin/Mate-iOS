//
//  DetailPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

protocol DetailPresenterProtocol: AnyObject {
    func viewDidLoad()
}

final class DetailPresenter: DetailPresenterProtocol {
    
    unowned var view: DetailViewControllerProtocol?
    let router: WeatherDetailRouter!
    let interactor: DetailInteractorProtocol!
    
    private var city: CityResult?
    
    init(
        view: DetailViewControllerProtocol,
        router: WeatherDetailRouter,
        interactor: DetailInteractorProtocol
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
   
    func viewDidLoad() {
        guard let city else { return }
        fetchCityDetailOutput(result: city)
    }
}

extension DetailPresenter: DetailInteractorOutputProtocol {
    func fetchCityDetailOutput(result: CityResult) {
        self.city = result
        view?.setDetailPageWith(result)
    }
}
