//
//  MapViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 5.04.2024.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import FiableRedux
import MateStorage
import MapKit
import CoreLocation

@Observable class MapViewModel {
    
    private(set) unowned var navigationController: UINavigationController?
    private let stores: StoresManager
    private(set) var state: State = .loading
    
    var events: [String] = []
    var onReload: (() -> Void)?
    
    init(
        navigationController: UINavigationController? = nil,
        stores: StoresManager = ServiceLocator.stores
    ) {
        self.navigationController = navigationController
        self.stores = stores
    }
    
    @MainActor
    func fetchEvents(isReload: Bool) async {
        if isReload {
            onReload?()
        }
        state = .loading
        do {
            events = try await loadSuggestedEvents()
           
            state = .content(events: events)
            
        } catch {
            DDLogError("⛔️ Error loading suggested themes: \(error)")
            state = .error
        }
    }

    @MainActor
    func loadSuggestedEvents() async throws -> [String] {
        try await withCheckedThrowingContinuation { continuation in
//            stores.dispatch(WordPressThemeAction.loadSuggestedThemes { result in
//                switch result {
//                case .success(let themes):
//                    continuation.resume(returning: themes)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            })
        }
    }
}

extension MapViewModel {
    enum State: Equatable {
        case loading
        case error
        case content(events: [String])
    }
}

//class MapViewModel: NSObject, ObservableObject {
//    
//    @Published var region: MKCoordinateRegion
//
//    @Published var trackingMode: MapUserTrackingMode = .follow
//
//    private(set) unowned var navigationController: UINavigationController?
//     
//    private let stores: StoresManager
//    
//    private let locationManager: LocationManagerDelegate
//
//    private var cancellables = Set<AnyCancellable>()
//    
//    init(
//        navigationController: UINavigationController? = nil,
//        stores: StoresManager = ServiceLocator.stores,
//        locationManager: LocationManagerDelegate = LocationManager()
//    ) {
        
//        self.region = MKCoordinateRegion(
//            center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
//            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        )
//        
//        self.navigationController = navigationController
//        self.stores = stores
//        self.locationManager = locationManager
//        super.init()
//        // Set the delegate of locationManager to self
//        (locationManager as? LocationManager)?.delegate = self
//        // Subscribe to changes in region
//        $region
//            .receive(on: DispatchQueue.main) // Ensure updates are performed on the main thread
//            .sink { [weak self] _ in
//                self?.objectWillChange.send()
//            }
//            .store(in: &cancellables)

//    }
//}

//extension MapViewModel: LocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.first else { return }
//        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
//        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
//        region = MKCoordinateRegion(center: center, span: span)
//    }
//}

//
//final class ThemesCarouselViewModel: ObservableObject {
//
//    @Published private(set) var state: State = .loading
//    @Published private var themes: [WordPressTheme] = []
//    @Published private var currentThemeID: String?
//
//    let siteID: Int64
//    let mode: Mode
//    private let stores: StoresManager
//    private let analytics: Analytics
//
//    /// Closure to be triggered when the theme list is reloaded.
//    var onReload: (() -> Void)?
//
//    init(siteID: Int64,
//         mode: Mode,
//         stores: StoresManager = ServiceLocator.stores,
//         analytics: Analytics = ServiceLocator.analytics) {
//        self.siteID = siteID
//        self.mode = mode
//        self.stores = stores
//        self.analytics = analytics
//        // current theme is only required for theme settings mode.
//        if mode == .themeSettings {
//            waitForCurrentThemeAndFinishLoading()
//        }
//    }
//
//    @MainActor
//    func fetchThemes(isReload: Bool) async {
//        if isReload {
//            onReload?()
//        }
//        state = .loading
//        do {
//            themes = try await loadSuggestedThemes()
//            /// Only update state immediately for the profiler flow.
//            /// The theme setting flow requires waiting for the current theme ID.
//            if mode == .storeCreationProfiler {
//                state = .content(themes: themes)
//            }
//        } catch {
//            DDLogError("⛔️ Error loading suggested themes: \(error)")
//            state = .error
//        }
//    }
//
//    func updateCurrentTheme(id: String?) {
//        currentThemeID = id
//    }
//
//    func trackViewAppear() {
//        let source = mode.analyticSource
//        analytics.track(event: .Themes.pickerScreenDisplayed(source: source))
//    }
//
//    func trackThemeSelected(_ theme: WordPressTheme) {
//        analytics.track(event: .Themes.themeSelected(id: theme.id))
//    }
//}
//
//private extension ThemesCarouselViewModel {
//    func waitForCurrentThemeAndFinishLoading() {
//        $themes.combineLatest($currentThemeID.dropFirst())
//            .map { themes, currentThemeID -> State in
//                let filteredThemes = themes.filter { $0.id != currentThemeID }
//                return filteredThemes.isEmpty ? .error : .content(themes: filteredThemes)
//            }
//            .assign(to: &$state)
//    }
//
//    @MainActor
//    func loadSuggestedThemes() async throws -> [WordPressTheme] {
//        try await withCheckedThrowingContinuation { continuation in
//            stores.dispatch(WordPressThemeAction.loadSuggestedThemes { result in
//                switch result {
//                case .success(let themes):
//                    continuation.resume(returning: themes)
//                case .failure(let error):
//                    continuation.resume(throwing: error)
//                }
//            })
//        }
//    }
//}
//

