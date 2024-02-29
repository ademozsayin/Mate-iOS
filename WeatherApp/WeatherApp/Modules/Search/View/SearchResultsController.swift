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
    
    @IBOutlet private weak var tableView: UITableView!
  
    var searchController: UISearchController?
    
    var presenter: SearchResultsPresenterProtocol?
    
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
    private func createSearchController() -> UISearchController {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = Localization.searchPlaceHolder
        return searchController
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
}

// MARK: - UITableViewDelegate - UITableViewDataSource
extension SearchResultsController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
