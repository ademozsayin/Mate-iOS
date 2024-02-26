//
//  DashboardPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

protocol DashboardPresenterProtocol: AnyObject {
    func viewDidLoad()
}


final class DashboardPresenter: DashboardPresenterProtocol {

    unowned var view: DashboardViewControllerProtocol?
    
    init(view: DashboardViewControllerProtocol){
        self.view = view
    }

    func viewDidLoad() {
        view?.setTitle("Moviehive")
    }
    
}

//extension DashboardPresenter: DashboardInteractorOutputProtocol {
//
//}
