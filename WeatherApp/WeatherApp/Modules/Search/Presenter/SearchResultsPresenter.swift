//
//  SearchResultsPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

/// Protocol defining the interactions handled by the SearchResultsViewController.
protocol SearchResultsPresenterProtocol: AnyObject {
    /// Called when the view is loaded and ready.
    func viewDidLoad()
    /// Updates the search results based on the provided query.
    ///
    /// - Parameter query: The search query entered by the user.
    func updateResults(query: String)
    /// The number of city results.
    var numberOfCityResult: Int { get }
    /// The searched city result.
    var searchedCity: CityResult? { get }
    
    // Store the last time fetchWeather was called
    var lastFetchTime: Date? { get set }
       
    // Threshold duration in seconds
    var fetchThreshold: TimeInterval { get }
    
    func removeQuerys()
}

/// Class responsible for presenting the search results view.
final class SearchResultsPresenter: SearchResultsPresenterProtocol {
    
    /// Reference to the search results view.
    unowned var view: SearchResultsControllerProtocol?
    /// Reference to the router handling navigation.
    let router: SearchResultsRouterProtocol!
    /// Reference to the interactor handling data retrieval.
    let interactor: SearchResultsInteractorProtocol!
    
    /// The searched city result.
    var searchedCity: CityResult?
    
    var lastFetchTime: Date?
    let fetchThreshold: TimeInterval = 0.3
    
    /// Initializes the presenter with required dependencies.
    ///
    /// - Parameters:
    ///   - view: The search results view.
    ///   - router: The router for navigation.
    ///   - interactor: The interactor for data retrieval.
    init(
        view: SearchResultsControllerProtocol,
        router: SearchResultsRouterProtocol,
        interactor: SearchResultsInteractorProtocol
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    /// The number of city results.
    var numberOfCityResult: Int {
        guard searchedCity != nil else { return 0 }
        return 1
    }
 
    /// Updates the search results based on the provided query.
    ///
    /// - Parameter query: The search query entered by the user.
    final func updateResults(query: String) {
        let currentTime = Date()
        
        /// Check if enough time has elapsed since the last fetch
        if let lastFetchTime = lastFetchTime,
           currentTime.timeIntervalSince(lastFetchTime) < fetchThreshold {
            /// Skip making the request if it's too soon
            return
        }
        
        /// Update the last fetch time
        lastFetchTime = currentTime
        
        /// Proceed with fetching weather data
        if query.count > 1 {
            interactor.fetchWeather(query: query)
        } else {
            searchedCity = nil
            view?.reloadData()
        }
    }
    
    /// Removes the searched city.
    final func removeQuerys() {
        self.searchedCity = nil
    }
    
    /// Called when the view is loaded and ready.
    final func viewDidLoad() {
        view?.setView()
    }
}

/// Extension to handle search results interactor output.
extension SearchResultsPresenter: SearchResultsInteractorOutputProtocol {
    
    /// Handles the fetched city result.
    ///
    /// - Parameter result: The result of fetching the city.
    func fetchCityOutput(result: Networking.SearchResult) {
        switch result {
        case .success(let city):
            self.searchedCity = city
            view?.reloadData()
        case .failure(let error):
            print(error.message ?? error.localizedDescription)
            view?.serverMessage(message: error.message ?? error.localizedDescription)
            view?.reloadData()

        }
    }
}
