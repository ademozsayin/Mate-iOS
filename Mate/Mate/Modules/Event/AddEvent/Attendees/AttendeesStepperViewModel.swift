//
//  AttendessStepperViewModel.swift
//  Mate
//
//  Created by Adem Özsayın on 2.05.2024.
//

import Foundation

final class AttendeesStepperViewModel: ObservableObject {
   
    @Published private(set) var quantity: Decimal {
            didSet {
                quantityUpdatedCallback(quantity)
                
                if quantity != oldValue {
                   if quantity == minimumQuantity {
                       notice = "Quantity set to minimum allowed."
                   } else if let max = maximumQuantity, quantity == max {
                       notice = "Quantity set to maximum allowed."
                   } else {
                       notice = nil  // Clear notice when within normal range
                   }
               }
            }
        }

    @Published var notice: String?  // Notice to show warnings or info
    
    /// Quantity as shown in the text field. This may be uncommitted, in which case it could differ from `quantity`
    ///
    @Published var enteredQuantity: Decimal

    let accessibilityLabel: String

    /// Minimum value of the product quantity
    ///
    private let minimumQuantity: Decimal

    /// Optional maximum value of the product quantity
    ///
    @Published var maximumQuantity: Decimal? {
            didSet {
                adjustQuantityWithinLimits()
            }
        }

    /// Whether the quantity can be decremented.
    ///
    var shouldDisableQuantityDecrementer: Bool {
        quantity <= minimumQuantity
    }

    /// Whether the quantity can be incremented.
    ///
    var shouldDisableQuantityIncrementer: Bool {
        guard let maximumQuantity else {
            return false
        }
        return quantity >= maximumQuantity
    }

    /// Closure to run when the quantity is changed.
    ///
    var quantityUpdatedCallback: (Decimal) -> Void

    /// Closure to run when the quantity is decremented below the minimum quantity.
    ///
    let removeProductIntent: (() -> Void)?

    init(quantity: Decimal,
         name: String,
         minimumQuantity: Decimal = 1,
         maximumQuantity: Decimal? = nil,
         quantityUpdatedCallback: @escaping (Decimal) -> Void,
         removeProductIntent: (() -> Void)? = nil) {
        self.quantity = quantity
        self.accessibilityLabel = "\(name): \(Localization.quantityLabel)"
        self.minimumQuantity = minimumQuantity
        self.maximumQuantity = maximumQuantity
        self.quantityUpdatedCallback = quantityUpdatedCallback
        self.removeProductIntent = removeProductIntent
        self.enteredQuantity = quantity
    }

    func resetEnteredQuantity() {
        enteredQuantity = quantity
    }

    func changeQuantity(to newQuantity: Decimal) {
        guard newQuantity != quantity else {
            // This stops unnecessary order edit submissions when editing starts via the text field
            return
        }

        guard newQuantity >= minimumQuantity else {
            // This shouldn't be possible, if the stepper is correctly disabled
            return
        }

        if let maximumQuantity,
            newQuantity > maximumQuantity {
            return
        }

        quantity = newQuantity
        quantityUpdatedCallback(newQuantity)
    }
    
    /// Ensures the current quantity does not exceed the maximum or fall below the minimum.
        func adjustQuantityWithinLimits() {
            if let max = maximumQuantity, quantity > max {
                quantity = max
            } else if quantity < minimumQuantity {
                quantity = minimumQuantity
            }
        }

    /// Increment the product quantity.
    ///
    func incrementQuantity() {
        changeQuantity(to: quantity + 1)
    }

    /// Decrement the product quantity.
    ///
    func decrementQuantity() {
        changeQuantity(to: quantity - 1)
    }
}

private enum Localization {
    static let quantityLabel = NSLocalizedString("Quantity", comment: "Accessibility label for product quantity field")
}
