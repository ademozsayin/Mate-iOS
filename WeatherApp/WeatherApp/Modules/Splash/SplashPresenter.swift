//
//  SplashPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

// MARK: - SplashPresenterProtocol
protocol SplashPresenterProtocol: AnyObject {
    
    /// Notifies the presenter that the view did appear.
    func viewDidAppear()
}

// MARK: - SplashPresenter
final class SplashPresenter: SplashPresenterProtocol {
    
    /// The view associated with the presenter.
    weak var view: SplashViewControllerProtocol?
    
    /// The router associated with the presenter.
    let router: SplashRouterProtocol?
    
    /// The interactor associated with the presenter.
    let interactor: SplashInteractorProtocol?
    
    /// Initializes the Splash Presenter.
    ///
    /// - Parameters:
    ///   - view: The view conforming to `SplashViewControllerProtocol`.
    ///   - router: The router conforming to `SplashRouterProtocol`.
    ///   - interactor: The interactor conforming to `SplashInteractorProtocol`.
    init(
        view: SplashViewControllerProtocol,
        router: SplashRouterProtocol,
        interactor: SplashInteractorProtocol
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    /// Notifies the presenter that the view did appear.
    func viewDidAppear() {
        interactor?.checkInternetConnection()
    }
}

// MARK: - SplashInteractorOutputProtocol
extension SplashPresenter: SplashInteractorOutputProtocol {
    
    /// Handles the internet connection status received from the interactor.
    ///
    /// - Parameters:
    ///   - status: A Boolean value indicating whether there is internet connection or not.
    func internetConnection(status: Bool) {
        if status {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.router?.navigate(.homeScreen)
            }
        } else {
            view?.noInternetConnection()
        }
    }
}
