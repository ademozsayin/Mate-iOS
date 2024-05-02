//
//  SelectAddress.swift
//  Mate
//
//  Created by Adem Özsayın on 29.04.2024.
//

import Foundation
import SwiftUI
import FiableFoundation
import MateNetworking
import MapKit

struct SelectAddress: View {
   
    private let safeAreaInsets: EdgeInsets
    @Environment(\.presentationMode) var presentation
    @State var viewModel: SelectLocationViewModel
    
    private let onSelection: ((GooglePlace) -> Void)?
    
    @State private var searchText = ""
    @State private var searchIsActive = false
    
    init(
        viewModel: SelectLocationViewModel,
        safeAreaInsets: EdgeInsets = .zero,
        onSelection: ((GooglePlace) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.safeAreaInsets = safeAreaInsets
        self.onSelection = onSelection
    }
    
    
    var body: some View {
        
        Group {
            let currentState = viewModel.syncState
            switch currentState {
            case .loading:
                loadingView()
            case .error:
                ErrorStateView(
                    title: "Error loading data.",
                    subtitle: "Something went wrong. Please try again.",
                    image: nil,
                    actionTitle: "Try Again",
                    actionHandler: {
                        Task {
//                            await viewModel.fetchPlaces()
                        }
                    }
                )
            case .content(let places):
                GeometryReader(content: { geometry in
                    ScrollView {
                        Toggle(isOn: $viewModel.showFavoritesOnly) {
                            Text("Favorites only")
                        }
                        .padding(20)
//                        ForEach(Array(places.enumerated()), id: \.element.place.id) { index, placeModel in
//                        List( Array (viewModel.filteredData.enumerated() ), id: \.element.place.id) { index, placeModel in
                        ForEach(Array(viewModel.filteredData.enumerated()), id: \.element.place.id) { index, placeModel in
                            HStack {
                                CollapsibleView(
                                    isCollapsed: $viewModel.googlePlaces[index].isCollapsed,
                                    safeAreaInsets: self.safeAreaInsets, label: {
                                        headerView(
                                            name: placeModel.place.name,
                                            categoryId: placeModel.place.eventCategoryID
                                        )
                                        
                                }, content: {
                                    collapseContentDetail(place: placeModel.place)
                                })
                                .onTapGesture {
                                    onSelection?(viewModel.googlePlaces[index].place)
                                    presentation.wrappedValue.dismiss()
                                }
                                if placeModel.isFavorite {
                                    Image(systemName: "star.fill")
                                }
                            }
                       
                        }
                        .searchable(text: $viewModel.searchText)
                    }
                })
            
            }
        }
        .background(Color.clear)
//        .onAppear {
//            Task {
//                await viewModel.syncDevices()
//            }
//        }
        .task {
            await viewModel.syncDevices()
        }
        .navigationTitle(Localization.title)
        .navigationBarTitleDisplayMode(.large)
        .wooNavigationBarStyle()
    }
}

// MARK: - ViewBuilders
private extension SelectAddress {
    @ViewBuilder
    func loadingView() -> some View {
        ZStack {
            ProgressView()
                .progressViewStyle(
                    IndefiniteCircularProgressViewStyle(
                        size: Layout.progressIndicatorSize,
                        lineWidth: Layout.progressIndicatorLineWidth
                    ))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
//    @ViewBuilder
    private func getImage(for categoryID: Int) -> some View {
        switch categoryID {
        case 1:
            Image(uiImage: UIImage.init(systemName: "soccerball")!)
        case 2:
            Image(uiImage: UIImage.init(systemName: "basketball")!)
        default:
            Image(uiImage: UIImage.init(systemName: "tennisball")!)
        }
        
    }
    
    private func headerView(name: String, categoryId: Int) -> some View {
        HStack {
            getImage(for: categoryId)
            Text(name)
                .font(.headline)
            Spacer()
           
        }
    }
    
    @ViewBuilder
    private func mapDetails(place: GooglePlace) -> some View {
        
        let latitude = Double(place.latitude) ?? 0.0
        let longitude = Double(place.longitude) ?? 0.0
        
        let x = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
        
        Map {
            Annotation(place.name, coordinate: x) {
                Circle()
                   .fill(Color.accentColor)
                   .frame(width: 30, height: 30)
                   .overlay {
                     Image(systemName: "mappin.circle")
                       .resizable()
                       .aspectRatio(contentMode: .fit)
                   }
            }
        }
    }
    
    @ViewBuilder
    private func collapseContentDetail(place: GooglePlace) -> some View  {
        VStack(spacing: 0) {
            TitleAndValueRow(
                title: "Address",
                value: .content(place.vicinity),
                selectionStyle: .none
            )
            TitleAndValueRow(
                title: "Rating",
                value: .content( "\(place.rating ?? 0 )" ),
                selectionStyle: .none
            )
            
            mapDetails(place: place)
                .frame(height: 250)

        }
    }
}

private extension SelectAddress {
    enum Constants {
        static let horizontalSpacing: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
    }
    
    enum Layout {
        static let verticalSpacing: CGFloat = 16
        static let progressIndicatorSize: CGFloat = 56
        static let progressIndicatorLineWidth: CGFloat = 6
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 152
        static let spacing: CGFloat = 40
        static let textSpacing: CGFloat = 16
    }

    enum Localization {
        static let title = NSLocalizedString(
            "Select Place",
            comment: "Title of selection while create event - Google Place"
        )
    }
}

#Preview {
    SelectAddress(viewModel: SelectLocationViewModel(), safeAreaInsets: .zero)
}
