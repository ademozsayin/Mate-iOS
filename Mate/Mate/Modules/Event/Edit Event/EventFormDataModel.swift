//
//  EventFormDataModel.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import Foundation
import FiableRedux


/// Describes a data model that contains necessary properties for rendering a event form (`EventFormViewController`).
protocol EventFormDataModel {
    // General
    var eventId: Int64 { get }
    var name: String { get }
    var google_place_id: String { get }
    // Price
    var startTime: String? { get }
    // Product Type
    var productType: MateCategory? { get }
    var maximumAttendees: String? { get }
    /// True if a product has been saved remotely.
    var existsRemotely: Bool { get }
    var status: EventStatus? { get }
}

// MARK: Helpers that can be derived from `EventFormDataModel`
//
extension EventFormDataModel {

}
