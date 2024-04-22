//
//  MapView.swift
//  Mate
//
//  Created by Adem Özsayın on 19.04.2024.
//


import SwiftUI
import MapKit
import Observation
import MateNetworking

struct MapView: View {
    
    @State var viewModel: MapViewModel
    @State private var lookAroundScene: MKLookAroundScene?
    @State private var selection: Int?
    @State private var selectedResult: MateEvent? // Use @State for selectedResult
    @State private var isTabBarHidden = false // State variable to control the visibility of the tab bar

    
    init(viewModel: MapViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Group {
            let currentState = viewModel.syncState
            switch currentState {
            case .loading:
                loadingView()
            case .error(let error):
                errorView(error)
            case .content(let events):
                makeMapContentView(for: events)
            }
        }
        .background(Color.clear)
    }
}

// MARK: - ViewBuilders
private extension MapView {
    
    @ViewBuilder
    func loadingView() -> some View {
        ZStack {
            Map()
                .blur(radius: 10.0)
            ProgressView()
                .progressViewStyle(IndefiniteCircularProgressViewStyle(size: Layout.progressIndicatorSize,
                                                                       lineWidth: Layout.progressIndicatorLineWidth))

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.clear)
            .edgesIgnoringSafeArea(.all)
            .hiddenTabBar()
        }
    }
    
    private func errorView(_ error: MapViewModel.ErrorType) -> some View {
        switch error {
        case .apiError:
            return AnyView(
                ErrorStateView(
                    title: "Error loading data.",
                    subtitle: "Something went wrong. Please try again.",
                    image: nil,
                    actionTitle: "Try Again",
                    actionHandler: {
//                        Task {
//                            await viewModel.fetchEvents(location: viewModel.userLocation)
//                        }
                    }
                )
            )
        case .locationPermissionDenied:
            return AnyView(
                ZStack {
                    Map()
                        .blur(radius: 10)
                    LocationRequestView()
                        .background(Color.clear)
                        .navigationBarHidden(true)
                        .hiddenTabBar()
                }
            )
        }
    }
    
    @ViewBuilder
    func makeMapContentView(for events: [MateEvent]) -> some View {
        Map(position: $viewModel.cameraPosition, selection: $selection) {
            UserAnnotation()
            ForEach(events, id: \.id) { event in
                if let coordinate = event.coordinate {
                    Marker(
                        event.name ?? "Mate Event",
                        systemImage: event.markerIcon,
                        coordinate: coordinate
                    )
                    .tint(event.tintColor)
                    .tag(event.id)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    if let selection {
                        if let item = viewModel.events.first(where: { $0.id == selection }) {
                            LocationPreviewLookAroundView(selectedResult: item, onClose: {
                                self.selection = nil
                            })
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: 300
                            )
                            .padding()
                        }
                    }
                }
                Spacer()
            }
            .background(.thinMaterial)
            .padding(.bottom)
        }
        .mapControls {
            MapUserLocationButton()
        }
        .showTabBar()
    }
}


private extension MapView {
    enum Constants {
        static let blockVerticalPadding: CGFloat = 32
        static let contentVerticalSpacing: CGFloat = 8
        static let contentPadding: CGFloat = 16
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}


#Preview {
    MapView(
        viewModel: MapViewModel()
    )
}

    

private enum Layout {
    static let progressIndicatorSize: CGFloat = 56
    static let progressIndicatorLineWidth: CGFloat = 6
    static let horizontalPadding: CGFloat = 16
    static let verticalPadding: CGFloat = 152
    static let spacing: CGFloat = 40
    static let textSpacing: CGFloat = 16
}

