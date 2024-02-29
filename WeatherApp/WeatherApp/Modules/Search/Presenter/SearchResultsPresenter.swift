//
//  SearchResultsPresenter.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

protocol SearchResultsPresenterProtocol: AnyObject {
   func viewDidLoad()
}

final class SearchResultsPresenter: SearchResultsPresenterProtocol{
    
    unowned var view: SearchResultsControllerProtocol?
    let router: SearchResultsRouterProtocol!
    let interactor: SearchResultsInteractorProtocol!
    
    init(
        view: SearchResultsControllerProtocol,
        router: SearchResultsRouterProtocol,
        interactor: SearchResultsInteractorProtocol
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
    }
    
    private var searchedMovies:[String] = []
    
    var numberOfMovies: Int {
        searchedMovies.count
    }
//    
//    func searchedMovie(index: Int) -> Movie? {
//        guard searchedMovies.count > index else {
//            return nil
//        }
//        return searchedMovies[index]
//    }
//    
//    func didSelectRowAt(index: Int) {
//        guard let movie = searchedMovie(index: index) else {return}
//        router.navigate(.detail(movie: movie))
//    }
//    
//    func updateResults(query: String) {
//        if query.count > 1 {
//            interactor.fetchMovies(query: query)
//        }else {
//            searchedMovies.removeAll()
//            view?.reloadData()
//        }
//        
//    }
    
    func removeMovies() {
        self.searchedMovies.removeAll()
    }
    
    func viewDidLoad() {
        view?.setView()
    }
    
}

extension SearchResultsPresenter: SearchResultsInteractorOutputProtocol{
    func fetchCityOutput(result: Networking.SearchResult) {
        
    }
    
//    func fetchMovieOutput(result: MovieListResult) {
//        
//        switch result{
//        case .success(let moviesResult):
//            self.searchedMovies = moviesResult.results ?? []
//            view?.reloadData()
//            
//        case .failure(let error):
//            print(error)
//        }
//        
//    }
    
}
