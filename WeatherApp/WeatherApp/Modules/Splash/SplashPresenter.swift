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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: NSNotification.Name(rawValue: "ReachiblityChange"),
            object: nil
        )
    }
    
    /// Notifies the presenter that the view did appear.
    func viewDidAppear() {
        interactor?.checkInternetConnection()
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        print(notification)
        // Update the view or inform the interactor about network status changes
        // Example:
        // view?.updateNetworkStatus()
        // interactor?.handleNetworkStatusChange()
//        interactor?.checkInternetConnection()
        ConnectionManager.isUnreachable { [weak self] _ in
            print("isUnreachable")
            self?.view?.isReachable(status: true)
        }
        
        ConnectionManager.isReachable {[weak self]  r  in
            print("isReachable")
            self?.view?.isReachable(status: false)
        }
    }
}

// MARK: - SplashInteractorOutputProtocol
extension SplashPresenter: SplashInteractorOutputProtocol {
    final func isReachable(status: Bool) {
        view?.isReachable(status: status)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.router?.navigate(.homeScreen)
        }
    }
    
    final func isUnreachable(status: Bool) {
        view?.isReachable(status: !status)
    }
}
