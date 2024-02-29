//
//  SearchResultsController.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import UIKit

// MARK: - SearchResultsControllerProtocol
protocol SearchResultsControllerProtocol: AnyObject {
    func reloadData()
    func setView()
    func serverMessage(message:String)
    var message:String? { get set }
}

// MARK: - SearchResultsController
final class SearchResultsController: UIViewController {
    
    // MARK: - IBOUtlets
    @IBOutlet private weak var tableView: UITableView!
  
    var searchController: UISearchController?
    
    var presenter: SearchResultsPresenterProtocol?
    
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
    }
}

// MARK: - SearchResultsControllerProtocol
extension SearchResultsController: SearchResultsControllerProtocol {
    final func setView() {
        tableView.delegate = self
        tableView.dataSource = self
      
        searchController = createSearchController()
        // Set the search bar as the header view of the table view
        tableView.tableHeaderView = searchController?.searchBar
        definesPresentationContext = true
    }
    
    final func reloadData() {
        tableView.reloadData()
    }
    
    // Builder method to create the search controller
    final func createSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Localization.searchPlaceHolder
        return searchController
    }
    
    func serverMessage(message: String) {
        self.message = message
    }
}

// MARK: - UISearchResultsUpdating - UISearchBarDelegate
extension SearchResultsController: UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchtext = searchController.searchBar.text else {
             return
        }
        presenter?.updateResults(query: searchtext)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        presenter?.removeQuerys()
        tableView.reloadData()
    }
}

// MARK: - UITableViewDelegate - UITableViewDataSource
extension SearchResultsController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if presenter?.numberOfCityResult == 0 {
            self.tableView.setEmptyMessage(self.message ?? "No data")
        } else {
            self.tableView.restore()
        }
        return presenter?.numberOfCityResult ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        cell.textLabel?.text = presenter?.searchedCity?.name ?? ""
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO: - navigate to detail
    }
}

// MARK: -Localization
extension SearchResultsController {
    enum Localization {
        static let searchPlaceHolder = NSLocalizedString(
            "Search",
            comment: "Placeholder text for search contoller"
        )
    }
}
