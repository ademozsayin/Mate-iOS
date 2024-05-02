//
//  SelectLocation.swift
//  Mate
//
//  Created by Adem Özsayın on 28.04.2024.
//

import SwiftUI
import Observation
import FiableRedux

struct SelectLocation: View {
    
    @State var viewModel: SelectLocationViewModel

    init(viewModel: SelectLocationViewModel) {
        self.viewModel = viewModel
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
                            await viewModel.fetchPlaces()
                        }
                    }
                )
            case .content(let places):
                SingleSelectionList(title: Localization.title,
                                    items: places,
                                    contentKeyPath: \.name,
                                    selected: $viewModel.selectedGooglePlace)
            }
        }
        .background(Color.clear)
        .onAppear {
            Task {
                await viewModel.fetchPlaces()
            }
        }
    }
}

// MARK: - ViewBuilders
private extension SelectLocation {
    
    
//    @ViewBuilder
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
}

// MARK: Constants
private extension SelectLocation {
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
    SelectLocation(viewModel: SelectLocationViewModel())
}


