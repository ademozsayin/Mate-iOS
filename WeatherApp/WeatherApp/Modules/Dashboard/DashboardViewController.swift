//
//  DashboardViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation
import UIKit
import Components

protocol DashboardViewControllerProtocol: AnyObject {
    func setTitle(_ title: String)
}

final class DashboardViewController: BaseViewController {
   
    var presenter: DashboardPresenter?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
    }
}

extension DashboardViewController: DashboardViewControllerProtocol {
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
