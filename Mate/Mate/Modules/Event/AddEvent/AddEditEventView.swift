//
//  AddEditEvent.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//
import SwiftUI
import FiableFoundation
import MateNetworking
/// A view for Adding or Editing a Coupon.


struct AddEditEventView: View {
    /// Set this closure with UIKit dismiss code. Needed because we need access to the UIHostingController `dismiss` method.
    ///
    var dismissHandler: () -> Void = {}
    
    /// Set this closure with SwiftUI onDisappear code. Needed because we need to set this event from a UIKit object.
    ///
    var onDisappear: () -> Void = {}
    
    private let categorySelectorConfig = ProductCategorySelector.Configuration.categoriesForCoupons
    private let categoryListConfig = EventCategoryConfiguration(searchEnabled: false, clearSelectionEnabled: false)
    
    @ObservedObject private var viewModel: AddEditEventViewModel
    
    @State private var showingSelectCategories: Bool = false
    @State private var isPickerVisible = false
    @State private var isLocationVisible = false
    @State private var selectedDate = Date()
    
    init(_ viewModel: AddEditEventViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    VStack (alignment: .leading, spacing: 12) {
                        
                        TitleAndTextFieldRow(title: "Event Name", placeholder: "Event name", text: $viewModel.eventName)
                        Divider()
                            .padding(.leading, 12)
                        
                        category
                        Divider()
                            .padding(.leading, 12)
                        
                        datePicker
                        Divider()
                            .padding(.leading, 12)
                        
                        address
                        Divider()
                            .padding(.leading, 12)
                        
                        stepper
                            .padding(.leading, 12)
                        Divider()
                            .padding(.leading, 12)
                        
                    }
                    .padding(.horizontal)
                    .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .horizontal))
                    .padding(.leading, 12)
                }
                .safeAreaInset(edge: .bottom) {
                    VStack {
                        Divider()
                            .frame(height: 16)
                            .foregroundColor(Color(.separator))
                        Button("Continue") {
                            //                            viewModel.continueButtonTapped()
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .disabled(!viewModel.canConfirmDetails)
                        .padding(16)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: {
                        dismissHandler()
                    })
                }
            }
            .notice($viewModel.notice)
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.large)
            .wooNavigationBarStyle()
        }
        .navigationViewStyle(.stack)
        .onDisappear {
            //            sonDisappear()
        }
    }
    
    var category: some View {
        TitleAndValueRow(title: Localization.category,
                         value: .placeholder(viewModel.selectedCategory?.name ?? ""),
                         selectionStyle: .disclosure) {
            showingSelectCategories.toggle()
        }
         .sheet(isPresented: $showingSelectCategories) {
             ProductCategorySelector(
                isPresented: $showingSelectCategories,
                viewConfig: categorySelectorConfig,
                categoryListConfig: categoryListConfig,
                viewModel: viewModel.categorySelectorViewModel ?? ProductCategorySelectorViewModel(
                    selectedCategory: nil,
                    selectedCategoryId: 1,
                    onCategorySelection: { _ in }
                )
             )
         }
    }
    
    var datePicker: some View {
        LazyNavigationLink(
            destination: DateTimePickerView(selectedDate: $selectedDate ) {
                isPickerVisible = false
                viewModel.setDate(selectedDate)
            }, isActive: $isPickerVisible) {
                TitleAndSubtitleRow(
                    title: "Select Date",
                    subtitle: viewModel.selectedDate?.toString(dateStyle: .medium, timeStyle: .short) ?? "Not set")
            }
    }
    
    var address: some View {
        LazyNavigationLink(
            destination: SelectAddress(
                viewModel: viewModel.selectLocationViewModel,
                safeAreaInsets: .zero,
                onSelection: { place in
                    viewModel.selectedGooglePlace = place
                }
            ),
            isActive: $isLocationVisible
        ) {
            HStack {
                TitleAndSubtitleRow(
                    title: "Location",
                    subtitle: viewModel.selectedGooglePlace?.name ?? "-"
                )
                DisclosureIndicator()
                    .padding(.trailing, 12)
            }
        }
    }
    
    var stepper: some View {
        HStack {
            Text(Localization.player)
            Spacer()
            ProductStepper(viewModel: viewModel.stepperViewModel)
            
        }
    }
}

private extension AddEditEventView  {
    enum Layout {
        static let padding: CGFloat = 16
        static let rowHeight: CGFloat = 44
        static let frameCornerRadius: CGFloat = 4
        static let borderLineWidth: CGFloat = 1
        static let inputFieldOverlayInset: CGFloat = 0.25
    }
}

//#Preview {
//    AddEditEventView(AddEditEventViewModel(onSuccess: { _ in }))
//}

// MARK: - Sample Data
#if DEBUG
extension MateEvent {
    static let sampleCoupon = MateEvent(
        id: -1,
        name: nil,
        startTime: nil,
        categoryID: nil,
        createdAt:" Date()",
        updatedAt: nil,
        userID: nil,
        address: nil,
        latitude: nil,
        longitude: nil,
        maxAttendees: "10",
        joinedAttendees: "0",
        category: nil,
        user: nil,
        status: .autoDraft)
}
#endif


// MARK: - Constants
//
private extension AddEditEventView {
    
    enum Constants {
        static let margin: CGFloat = 16
        static let verticalSpacing: CGFloat = 8
        static let iconSize: CGFloat = 16
    }
    
    enum Localization {
        static let cancelButton = NSLocalizedString(
            "Cancel",
            comment: "Cancel button in the navigation bar of the view for adding or editing a coupon.")
        
        
        static let category = NSLocalizedString(
            "Category",
            comment: "Add event input name"
        )
        
        static let player = NSLocalizedString(
            "Player",
            comment: ""
        )
    }
}

private extension ProductCategorySelector.Configuration {
    static let categoriesForCoupons: Self = .init(
        title: Localization.title,
        doneButtonSingularFormat: Localization.doneSingularFormat,
        doneButtonPluralFormat: Localization.donePluralFormat
    )
    
    enum Localization {
        static let title = NSLocalizedString("Select category", comment: "Title for the Select Categories screen")
        static let doneSingularFormat = NSLocalizedString(
            "Select %1$d Category",
            comment: "Button to submit selection on the Select Categories screen when 1 item is selected")
        static let donePluralFormat = NSLocalizedString(
            "Select %1$d Categories",
            comment: "Button to submit selection on the Select Categories screen " +
            "when more than 1 item is selected. " +
            "Reads like: Select 10 Categories")
    }
}
