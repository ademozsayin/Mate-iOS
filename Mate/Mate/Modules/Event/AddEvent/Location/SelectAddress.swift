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
import Kingfisher

struct SelectAddress: View {
   
    private let safeAreaInsets: EdgeInsets
    @Environment(\.presentationMode) var presentation
    @ObservedObject var viewModel: SelectLocationViewModel
    
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

                        ForEach(Array(viewModel.filteredData.enumerated()), id: \.element.place.id) { index, placeModel in
                            HStack {
                                let isSelected = (viewModel.selectedPlaceID == placeModel.place.placeID)
 
                                SelectAddress.Row(
                                    title: placeModel.place.name,
                                    titleBadge: "",
                                    iconBadge: .dot,
                                    description: "",
                                    icon: .local(getUIImage(for: placeModel.place.eventCategoryID)),
                                    chevron: .leading,
                                    selected: isSelected,
                                    displayMode: .compact,
                                    selectionStyle: .checkmark,
                                    iconForegroundColor: iconTint(for: placeModel.place.eventCategoryID))
                                
                                    .padding(EdgeInsets(top: 5, leading: 16, bottom: 5, trailing: 16))
                                    .onTapGesture {
                                        viewModel.selectedPlaceID = placeModel.place.placeID
                                        onSelection?(placeModel.place )
                                        presentation.wrappedValue.dismiss()
                                    }
                                  
                                if placeModel.isFavorite {
                                    Image(systemName: "star.fill")
                                }
                            }
                            .background(Color(.systemBackground)) // Ensure the entire HStack has a background
                            .cornerRadius(16)
                            .padding([.leading, .trailing], 16)
                            .padding([.top, .bottom], 5) // Apply vertical padding to achieve 10px between rows
                        }
                        .searchable(text: $viewModel.searchText)
                    }
                })
            
            }
        }
        .background(Color(.listBackground).edgesIgnoringSafeArea(.all))
        .onAppear{
//            print(viewModel.selectedGooglePlace?.place.name)
        }
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
    private func getImage(for categoryID: Int) -> Image? {
        switch categoryID {
        case 1:
            Image(systemName: "soccerball").foregroundColor(Color(uiColor: .jetpackGreen)) as? Image
        case 2:
            Image(systemName: "basketball").foregroundColor(Color(uiColor: .wooOrange)) as? Image
        default:
            Image(systemName: "tennisball").foregroundColor(Color(uiColor: .green)) as? Image
        }
        
    }
    
    private func getUIImage(for categoryID: Int) -> UIImage {
        switch categoryID {
        case 1:
            (UIImage.init(systemName: "soccerball")?.withTintColor(.systemGreen, renderingMode: .alwaysTemplate))!
        case 2:
            (UIImage.init(systemName: "basketball")?.withTintColor(.wooOrange, renderingMode: .alwaysTemplate))!
        default:
            (UIImage.init(systemName: "tennisball")?.withTintColor(.jetpackGreen, renderingMode: .alwaysTemplate))!
        }
        
    }
    
    private func iconTint(for categoryID: Int) -> Color {
        switch categoryID {
        case 1:
            return Color(uiColor: .systemGreen)
        case 2:
            return Color(uiColor: .wooOrange)
        default:
            return Color(uiColor: .jetpackGreen)
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
}

private extension SelectAddress {
    enum Constants {
    
        static let verticalSpacing: CGFloat = 16
        static let progressIndicatorSize: CGFloat = 56
        static let progressIndicatorLineWidth: CGFloat = 6
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 152
        static let spacing: CGFloat = 40
        static let textSpacing: CGFloat = 16
        
        static let cornerRadius: CGFloat = 10
        static let padding: CGFloat = 16
        static let rowVerticalPadding: CGFloat = 8
        static let topBarSpacing: CGFloat = 2
        static let avatarSize: CGFloat = 40
        static let chevronSize: CGFloat = 20
        static let iconSize: CGFloat = 20
        static let trackingOptionKey = "option"
        static let dotBadgePadding = EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 2)
        static let dotBadgeSize: CGFloat = 6
        
        static let zStackWidth: CGFloat = 48
        static let vStackPadding: CGFloat = 16
        static let hStackPadding: CGFloat = 10
        static let height: CGFloat = 60
        static let compactHeight: CGFloat = 52
        static let imageSize: CGFloat = 22
        
        /// Spacing for the badge view in the avatar row.
        ///
        static func badgeSpacing(sizeCategory: ContentSizeCategory) -> CGFloat {
            sizeCategory.isAccessibilityCategory ? .zero : 4
        }
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
    
    /// Reusable List row for the Select Adress menu
    ///
    struct Row: View {

        /// Image source for the icon/avatar.
        ///
        enum Icon {
            case local(UIImage)
        }

        /// Style for the chevron indicator.
        ///
        enum Chevron {
            case none
            case down
            case leading

            var asset: UIImage {
                switch self {
                case .none:
                    return UIImage()
                case .down:
                    return .chevronDownImage
                case .leading:
                    return .chevronImage
                }
            }
        }
        
        enum SelectionStyle {
            case checkmark
            case checkcircle

            func image(selected: Bool, isEnabled: Bool) -> UIImage? {
                switch (self, selected, isEnabled) {
                case (.checkmark, true, true):
                    return .checkmarkStyledImage
                case (.checkmark, _, _):
                    return nil
                case (.checkcircle, true, _):
                    return .checkCircleImage.withRenderingMode(.alwaysTemplate)
                case (.checkcircle, false, _):
                    return .checkEmptyCircleImage
                }
            }
        }
        
        enum DisplayMode {
            case compact
            case full

            var minHeight: CGFloat {
                switch self {
                case .compact:
                    return Constants.compactHeight
                case .full:
                    return Constants.height
                }
            }
        }

        enum Alignment {
            case leading
            case trailing

            var leadingSpace: CGFloat {
                switch self {
                case .leading:
                    return 0
                case .trailing:
                    return Constants.vStackPadding
                }
            }

            var trailingSpace: CGFloat {
                switch self {
                case .leading:
                    return Constants.vStackPadding
                case .trailing:
                    return 0
                }
            }
        }

        /// Row Title
        ///
        let title: String

        /// Text badge displayed adjacent to the title
        ///
        let titleBadge: String?

        /// Badge displayed on the icon.
        ///
        let iconBadge: HubMenuBadgeType?

        /// Row Description
        ///
        let description: String

        /// Row Icon
        ///
        let icon: Icon

        /// Row chevron indicator
        ///
        let chevron: Chevron

        var titleAccessibilityID: String?
        var descriptionAccessibilityID: String?
        var chevronAccessibilityID: String?
                
        let selected: Bool
        let displayMode: DisplayMode
        let selectionStyle: SelectionStyle
        
        
        let iconForegroundColor: Color?
        
        @Environment(\.isEnabled) private var isEnabled
        @Environment(\.sizeCategory) private var sizeCategory

        var body: some View {
            HStack(spacing: SelectAddress.Constants.padding) {
                HStack(spacing: .zero) {
                    Text("")

                    ZStack {
                        // Icon
                        Group {
                            switch icon {
                            case .local(let asset):
                                Circle()
                                    .fill(Color(.init(light: .listBackground, dark: .secondaryButtonBackground)))
                                    .frame(width: SelectAddress.Constants.avatarSize, height: SelectAddress.Constants.avatarSize)
                                    .overlay {
                                        Image(uiImage: asset)
                                            .resizable()
                                            .foregroundColor(iconForegroundColor)
                                            .frame(width: SelectAddress.Constants.iconSize, height: SelectAddress.Constants.iconSize)
                                    }
                               
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            // Badge
                            if case .dot = iconBadge {
                                Circle()
//                                    .fill(Color(.accent))
                                    .frame(width: SelectAddress.Constants.dotBadgeSize)
                                    .padding(SelectAddress.Constants.dotBadgePadding)

                            }
                        }
                    }
                }


                // Title & Description
                VStack(alignment: .leading, spacing: SelectAddress.Constants.topBarSpacing) {

                    AdaptiveStack(horizontalAlignment: .leading, spacing: Constants.badgeSpacing(sizeCategory: sizeCategory)) {
                        Text(title)
                            .headlineStyle()
                            .accessibilityIdentifier(titleAccessibilityID ?? "")

                        if let titleBadge, titleBadge.isNotEmpty {
                            BadgeView(text: titleBadge)
                        }
                    }

                    Text(description)
                        .subheadlineStyle()
                        .accessibilityIdentifier(descriptionAccessibilityID ?? "")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    if let image = selectionStyle.image(selected: selected, isEnabled: isEnabled) {
                        Image(uiImage: image)
                            .frame(width: Constants.imageSize, height: Constants.imageSize)
                            .iconStyle(isEnabled)
                    }
                }
                .frame(width: Constants.zStackWidth)
                
                Image(uiImage: .infoImage)
                    .resizable()
                    .frame(width: SelectAddress.Constants.chevronSize, height: SelectAddress.Constants.chevronSize)
                    .flipsForRightToLeftLayoutDirection(true)
                    .foregroundColor(Color(.textSubtle))
                    .accessibilityIdentifier(chevronAccessibilityID ?? "")
                
                // Tap Indicator
                Image(uiImage: chevron.asset)
                    .resizable()
                    .frame(width: SelectAddress.Constants.chevronSize, height: SelectAddress.Constants.chevronSize)
                    .flipsForRightToLeftLayoutDirection(true)
                    .foregroundColor(Color(.textSubtle))
                    .accessibilityIdentifier(chevronAccessibilityID ?? "")
                    .renderedIf(chevron != .none)
            }
            .padding(.vertical, Constants.rowVerticalPadding)
        }
    }
    
}

#Preview {
    SelectAddress.Row(
        title: "Adem",
        titleBadge: "",
        iconBadge: .dot,
        description: "A",
        icon: .local(.addImage),
        chevron: .leading,
        selected: true,
        displayMode: .full,
        selectionStyle: .checkmark,
        iconForegroundColor: nil)
}
