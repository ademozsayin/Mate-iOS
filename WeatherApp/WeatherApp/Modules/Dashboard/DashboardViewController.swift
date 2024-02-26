//
//  DashboardViewController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 26.02.2024.
//

import Foundation

protocol DashboardViewControllerProtocol: AnyObject {
    func setTitle(_ title: String)
}

class DashboardViewController: BaseViewController, LoadingShowable, UISearchControllerDelegate {

}
