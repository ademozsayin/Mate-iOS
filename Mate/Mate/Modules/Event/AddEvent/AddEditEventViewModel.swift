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
    @Published var categoryID: Int64
    private var subscriptions: Set<AnyCancellable> = []


    /// View model for the category selector
    ///
    var categorySelectorViewModel: ProductCategorySelectorViewModel {
        .init( selectedCategory: categoryID) { [weak self] category in
            self?.categoryID = Int64(category.id)
            self?.selectedCategory = category
            print("selected category : \(category.name)")
        }
    }
    
    // State variable to track the selected category
    @Published var selectedCategory: MateCategory? = nil
    @Published var selectedGooglePlace: GooglePlace? = nil
    /// Init method for coupon creation
    ///
    init(
         stores: StoresManager = ServiceLocator.stores,
         storageManager: StorageManagerType = ServiceLocator.storageManager,
         onSuccess: @escaping (MateEvent) -> Void
    ) {
        editingOption = .creation
        self.stores = stores
        self.storageManager = storageManager
        self.onSuccess = onSuccess
        
        self.eventName = ""
        
        categoryID = 1
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
    }

    enum Localization {
       
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
    }
}
