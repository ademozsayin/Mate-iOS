//
//  SearchResultsController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import UIKit

protocol SearchResultsControllerProtocol: AnyObject {
    func reloadData()
    func setView()
}


final class SearchResultsController: UIViewController {
   
    var presenter: SearchResultsPresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .purple
        // Do any additional setup after loading the view.
    }
}

extension SearchResultsController: SearchResultsControllerProtocol {
    func reloadData() {
//        <#code#>
    }
    
    func setView() {
//        <#code#>
    }
}
