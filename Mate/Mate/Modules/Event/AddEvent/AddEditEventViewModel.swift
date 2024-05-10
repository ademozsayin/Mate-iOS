//
//  AddEditEventViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import Foundation
import FiableRedux
import Combine
import UIKit
import FiableFoundation
import protocol MateStorage.StorageManagerType
import SwiftUI

/// View model for `AddEditCoupon` view
///
final class AddEditEventViewModel: ObservableObject {
    
    /// Based on the Editing Option, the `AddEditCoupon` view can be in Creation or Editing mode.
    ///
    private let editingOption: EditingOption
    
    private let onSuccess: (MateEvent) -> Void
    
    /// Defines the current notice that should be shown.
    /// Defaults to `nil`.
    ///
    @Published var notice: Notice?
    
    var title: String {
        switch editingOption {
        case .creation:
            return Localization.createCouponTitle
        case .editing:
            return Localization.editCouponTitle
        }
    }
    
    
    private(set) var event: MateEvent?
    private let stores: StoresManager
    private let storageManager: StorageManagerType
    
    @Published var isLoading: Bool = false
    @Published var showingCouponCreationSuccess: Bool = false
    
    @Published var eventName: String
    @Published var categoryID: Int64 = 1
    @Published var selectedDate: Date?
    
    
    private var subscriptions: Set<AnyCancellable> = []
    
    @Published var showingSelectCategories: Bool = false
    
    
    // State variable to track the selected category
    @Published var selectedCategory: MateCategory? {
        didSet {
            updateStepperMaximum(for: selectedCategory)
            self.notice = NoticeFactory.createEventNoticeForCategorySelection(selectedCategory)
        }
    }
    
    @Published var selectedGooglePlace: GooglePlace? = nil
    
    @State var stepperViewModel: AttendeesStepperViewModel
    
    @State var selectLocationViewModel: SelectLocationViewModel

    /// View model for the category selector
    ///
    var categorySelectorViewModel: ProductCategorySelectorViewModel?
    
    init(event: MateEvent?,
        stores: StoresManager = ServiceLocator.stores,
        storageManager: StorageManagerType = ServiceLocator.storageManager,
        onSuccess: @escaping (MateEvent) -> Void
    ) {
        editingOption = .creation
        self.event = event
        self.stores = stores
        self.storageManager = storageManager
        self.onSuccess = onSuccess
        self.eventName = ""
        self.categoryID = Int64(self.event?.category?.id ?? 1)
        self.selectedCategory = self.event?.category ?? nil
        
        self.selectLocationViewModel = SelectLocationViewModel()
        
        self.stepperViewModel = AttendeesStepperViewModel(
            quantity: 2,
            name: Localization.player,
            minimumQuantity: 2,
            maximumQuantity: 14,
            quantityUpdatedCallback: { _ in }  // Temporary empty closure
        )
        
        // Now that self is fully initialized, set the real callback
        self.stepperViewModel.quantityUpdatedCallback = {  [weak self ] newQuantity in
            guard let self else { return }
            print("Updated quantity to \(newQuantity)")
            self.updateEventCapacity(with: newQuantity)
        }
        
        self.setupCategorySelectorViewModel()

    }
    
    private func setupCategorySelectorViewModel() {
         self.categorySelectorViewModel = ProductCategorySelectorViewModel(
             selectedCategory: self.event?.category,
             selectedCategoryId: Int64(self.event?.category?.id ?? 1),
             onCategorySelection: { [weak self] category in
                 guard let self = self else { return }
                 self.selectedCategory = category
             }
         )
     }
    

    private func updateStepperMaximum(for category: MateCategory?) {
        if let category = category {
            let newMax = determineMaxAttendees(for: category)
            stepperViewModel.maximumQuantity = newMax
            // Check if the current quantity exceeds the new maximum and adjust if necessary
            if stepperViewModel.quantity > newMax {
                stepperViewModel.changeQuantity(to: newMax)
            }
            stepperViewModel.adjustQuantityWithinLimits()  // Ensure the current quantity is adjusted
            
        }
    }
    
    /// Updates the event capacity and performs additional business logic
    private func updateEventCapacity(with newQuantity: Decimal) {
        stepperViewModel.changeQuantity(to: newQuantity)
        stepperViewModel.enteredQuantity = newQuantity
    }
    
    private func determineMaxAttendees(for category: MateCategory) -> Decimal {
        // Implement your logic to determine max attendees based on category
        switch category.id {
        case 1:
            return 14
        case 2:
            return 10
        default:
            return 4
        }
    }
    
    func completeCouponAddEdit(coupon: MateEvent, onUpdateFinished: @escaping () -> Void) {
        switch editingOption {
        case .creation:
            createCoupon(coupon: coupon)
        case .editing:
            // TODO: -
            print("editting ")
        }
    }
    
    private func createCoupon(coupon: MateEvent) {
        
    }
    
    
    var canConfirmDetails: Bool {
        selectedGooglePlace != nil && eventName.isNotEmpty && selectedDate != nil && selectedCategory != nil
    }
    // Method to set the date from the UI
    func setDate(_ date: Date?) {
        self.selectedDate = date
    }
    
    // Method to clear the date when needed
    func clearDate() {
        self.selectedDate = nil
    }
    
    /// Default coupon when coupon creation is initiated
    private lazy var defaultCoupon: MateEvent = {
        .init(id: -1,
              name: nil,
              startTime: nil,
              categoryID: nil,
              createdAt: nil,
              updatedAt: nil,
              userID: nil,
              address: nil,
              latitude: nil,
              longitude: nil,
              maxAttendees: nil,
              joinedAttendees: nil,
              category: nil,
              user: nil,
              status: nil)
    }()
    
    /// Coupon generated from input
    var populatedCoupon: MateEvent {
        
        return defaultCoupon
    }
    
    func validateCouponLocally(_ coupon: MateEvent) -> EventError? {
        return nil
        //        if coupon.code.isEmpty {
        //            return .couponCodeEmpty
        //        }
        //
        //        amountWarningTimer?.invalidate()
        //        isDisplayingAmountWarning = false
        //
        //        return nil//svalidatePercentageAmountInput(withWarning: false)
    }
    
    enum EditingOption {
        case creation
        case editing
    }
    
    enum EventError: Error, Equatable {
        case couponCodeEmpty
        case couponPercentAmountInvalid
        case other(error: Error)
        
        static func ==(lhs: EventError, rhs: EventError) -> Bool {
            return lhs.localizedDescription == rhs.localizedDescription
        }
    }
    
}

// MARK: - Helpers
//
private extension AddEditEventViewModel {
    
}

// MARK: - Constants
//
private extension AddEditEventViewModel {
    
    /// Coupon notices
    ///
    enum NoticeFactory {
        /// Returns a default coupon editing/creation error notice.
        ///
        static func createCouponErrorNotice(_ couponError: AddEditEventViewModel.EventError,
                                            editingOption: AddEditEventViewModel.EditingOption) -> Notice {
            switch couponError {
            case .couponCodeEmpty:
                return Notice(title: Localization.errorCouponCodeEmpty, feedbackType: .error)
            case .couponPercentAmountInvalid:
                return Notice(title: Localization.errorCouponAmountInvalid, feedbackType: .error)
            default:
                switch editingOption {
                case .editing:
                    return Notice(title: Localization.genericUpdateCouponError, feedbackType: .error)
                case .creation:
                    return Notice(title: Localization.genericCreateCouponError, feedbackType: .error)
                }
            }
        }
        
        static func createEventNoticeForCategorySelection(_ category: MateCategory?) -> Notice {
            let title = String.localizedStringWithFormat(Localization.changeCategoriesButton, category?.name ?? "Unknown")
            return Notice(title: title, feedbackType: .warning)
        }
    }
    
    enum Localization {
        
        static let changeCategoriesButton = NSLocalizedString(
            "You have changed category to %@.",
            comment: "Button for specify the product categories where a coupon can be applied in the view for adding or editing a coupon. " +
            "Reads like: Edit Categories")
        
        static let addDescriptionButton = NSLocalizedString("Add Description (Optional)",
                                                            comment: "Button for adding a description to a coupon in the view for adding or editing a coupon.")
        static let editDescriptionButton = NSLocalizedString("Edit Description",
                                                             comment: "Button for editing the description of a coupon in the" +
                                                             " view for adding or editing a coupon.")
        static let couponExpiryDatePlaceholder = NSLocalizedString(
            "None",
            comment: "Coupon expiry date placeholder in the view for adding or editing a coupon")
        static let errorCouponCodeEmpty = NSLocalizedString("The coupon code couldn't be empty",
                                                            comment: "Error message in the Add Edit Coupon screen when the coupon code is empty.")
        static let errorCouponAmountInvalid = NSLocalizedString("The coupon amount cannot be greater than" +
                                                                " 100 for percentage discounts",
                                                                comment: "Error message in the Add Edit Coupon screen when the coupon amount is " +
                                                                "higher than 100% for a percentage discount")
        static let genericUpdateCouponError = NSLocalizedString("Something went wrong while updating the coupon.",
                                                                comment: "Error message in the Add Edit Coupon screen " +
                                                                "when the update of the coupon goes in error.")
        static let genericCreateCouponError = NSLocalizedString("Something went wrong while creating the coupon.",
                                                                comment: "Error message in the Add Edit Coupon screen " +
                                                                "when the creation of the coupon goes in error.")
        static let editProductsButton = NSLocalizedString(
            "Edit Products (%1$d)",
            comment: "Button specifying the number of products applicable to a coupon in the view for adding or editing a coupon. " +
            "Reads like: Edit Products (2)")
        static let editProductCategoriesButton = NSLocalizedString(
            "Edit Product Categories (%1$d)",
            comment: "Button for specify the product categories where a coupon can be applied in the view for adding or editing a coupon. " +
            "Reads like: Edit Categories")
        static let createCouponTitle = NSLocalizedString("Create event", comment: "Title of the Create coupon screen")
        static let editCouponTitle = NSLocalizedString("Edit coupon", comment: "Title of the Edit coupon screen")
        static let saveButton = NSLocalizedString("Save", comment: "Action for saving a Coupon remotely")
        static let createButton = NSLocalizedString("Create", comment: "Action for creating a Coupon remotely")
        static let player = NSLocalizedString("Player", comment: "")

    }
}
