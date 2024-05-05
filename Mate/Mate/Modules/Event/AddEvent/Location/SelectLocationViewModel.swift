//
//  File.swift
//  Mate
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import Observation
import FiableRedux
import SwiftUI
import protocol MateStorage.StorageManagerType

final class SelectLocationViewModel: ObservableObject {
    
    private var resultsController: ResultsController<StorageGooglePlace>

    private(set) var syncState = SyncState.loading {
        didSet {
            DDLogInfo("✅ State: \(SyncState.loading)")
        }
    }
    
    @Published var googlePlaces:[GooglePlaceLocationViewRowModel] = []
    
    @Published var eventName: String
    @Published var searchText = ""
  
    private let stores: StoresManager
    private let storageManager: StorageManagerType

    @Published private var fetchedTopics: [GooglePlace] = []
    @Published  private var isSyncingData: Bool = false {
        didSet {
            DDLogInfo("✅ Is Syncing Data: \(isSyncingData)")
        }
    }
    @Published  private var syncError: Error?
    
    @Published var selectedPlaceID: String? {
        didSet {
            print("selectedPlaceID: \(selectedPlaceID)")
        }
    }
    
    // MARK: - Init
    init(
        stores: StoresManager = ServiceLocator.stores,
        storageManager: StorageManagerType = ServiceLocator.storageManager
    ) {
        self.stores = stores
        self.storageManager = storageManager
      
        self.eventName = ""
       
        let sortDescriptorByID = NSSortDescriptor(keyPath: \StorageGooglePlace.name, ascending: true)
        self.resultsController = ResultsController<StorageGooglePlace>(storageManager: storageManager,
                                                                               matching: nil,
                                                                               sortedBy: [sortDescriptorByID])
        
        configureResultsController()
//        configureSyncState()
        self.selectedPlaceID = nil
        
    }
    
    var filteredData: [GooglePlaceLocationViewRowModel] {
        
        if showFavoritesOnly {
            return googlePlaces.filter {  $0.isFavorite }
        }
        
        if searchText.isEmpty {
            return googlePlaces
        }
        
        return googlePlaces.filter {  $0.place.name.localizedCaseInsensitiveContains(searchText) }
    }

    var showFavoritesOnly = false
    
    @MainActor
    func syncDevices() async {
        syncError = nil
        isSyncingData = true
//        syncState = .loading
        do {
            try await withCheckedThrowingContinuation { continuation in
                stores.dispatch(GooglePlacesAction.getGooglePlaces() { [weak self] result in
                    guard let self else { return }
                    switch result {
                    case .success(let places):
                        guard let data = places.data else {
                            return
                        }
                        continuation.resume(returning: Void())

                        let places = data.map { GooglePlaceLocationViewRowModel(place: $0, isCollapsed: true, isFavorite: false, isSelected: false) }
                        syncState = .content(events: places)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                })
            }
        } catch {
            DDLogError("⛔️ Error syncing Google Places: \(error)")
            syncError = error
            syncState = .error
        }
        isSyncingData = false

    }
    
}

private extension SelectLocationViewModel {
    /// Performs initial fetch from storage and updates results.
    func configureResultsController() {
        resultsController.onDidChangeContent = { [weak self] in
            self?.updateResults()
        }
        resultsController.onDidResetContent = { [weak self] in
            self?.updateResults()
        }

        do {
            try resultsController.performFetch()
            DDLogInfo("✅ Feth from core data")
            updateResults()
        } catch {
//            ServiceLocator.crashLogging.logError(error)
        }
    }

    func updateResults() {
        DDLogInfo("✅ Updating result")
        fetchedTopics = resultsController.fetchedObjects
        googlePlaces = fetchedTopics.map { GooglePlaceLocationViewRowModel(place: $0, isCollapsed: true, isFavorite: false, isSelected: false) }
        syncState = .content(events: googlePlaces)
    }
}


extension SelectLocationViewModel {
    enum SyncState: Equatable {
        case loading
        case error
        case content(events: [GooglePlaceLocationViewRowModel])
    }
}


struct GooglePlaceLocationViewRowModel: Hashable, Identifiable {
    let id: UUID
    var place: GooglePlace
    var isCollapsed: Bool
    var isFavorite: Bool
    var isSelected: Bool

    init(place: GooglePlace, isCollapsed: Bool, isFavorite: Bool, isSelected: Bool) {
        self.id = UUID() // Generating a unique identifier
        self.place = place
        self.isCollapsed = isCollapsed
        self.isFavorite = false
        self.isSelected = false
    }

    mutating func toggleExpansion() {
        isCollapsed.toggle()
    }

    static func == (lhs: GooglePlaceLocationViewRowModel, rhs: GooglePlaceLocationViewRowModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
