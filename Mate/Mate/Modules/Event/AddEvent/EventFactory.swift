//
//  EventFactory.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import FiableRedux
import struct MateNetworking.MateEvent
/// Creates a new product given a set of parameters.
///
struct EventFactory {
    /// Creates a new product (does not exist remotely) for a site ID of a given type.
    ///
    /// - Parameters:
    ///   - type: The type of the product.
    ///   - isVirtual: Whether the product is virtual (for simple products).
    ///   - siteID: The site ID where the product is added to.
    ///   - status: The status of the new product.
    func createNewEvent(type: BottomSheetProductType?, isVirtual: Bool) -> MateEvent? {
        return createEmptyEvent(type: type, isVirtual: isVirtual)
    }

    /// Copies a product by cleaning properties like `id, name, statusKey, and groupedProducts` to their default state.
    /// This is useful to turn an existing (on core) `auto-draft` product into a new app-product ready to be saved.
    ///
    /// - Parameters:
    ///   - existingProduct: The product to copy.
    ///   - status: The status of the new product.
//    func newEvent(from existingEvent: MateEvent) -> MateEvent {
//        return existingEvent.copy(id: 0, name: "")
//    }
}

private extension EventFactory {
    func createEmptyEvent(type: BottomSheetProductType? ,isVirtual: Bool) -> MateEvent {
        MateEvent(id: 0,
                  name: nil,
                  startTime: nil,
                  categoryID: "1",
                  createdAt: nil,
                  updatedAt: nil,
                  userID: nil,
                  address: nil,
                  latitude: nil,
                  longitude: nil,
                  maxAttendees: nil,
                  joinedAttendees: nil,
                  category: nil,
                  user: nil)
    }
            
}
