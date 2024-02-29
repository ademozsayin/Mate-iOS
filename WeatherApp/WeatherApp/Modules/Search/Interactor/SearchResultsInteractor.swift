//
//  SearchResultsInteractor.swift
//  WeatherApp
//
//  Created by Adem Özsayın on 1.03.2024.
//

import Foundation
import Networking

protocol SearchResultsInteractorProtocol: AnyObject {
    func fetchWeather(query: String)
}

protocol SearchResultsInteractorOutputProtocol: AnyObject{}

final class SearchResultsInteractor{
    var output: SearchResultsInteractorOutputProtocol?
    var service: WeatherProtocol
    
    init(
        service: WeatherProtocol = WeatherAPI(),
        output: SearchResultsInteractorOutputProtocol? = nil
    ) {
        self.output = output
        self.service = service
    }
}

extension SearchResultsInteractor: SearchResultsInteractorProtocol{
    
    func fetchWeather(query: String) {
        // TODO: - Fetch
    }
}


