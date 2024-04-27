//
//  EventFormActionsFactoryProtocol.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import Foundation

/// Creates actions available on various sections of a product form.
protocol EventFormActionsFactoryProtocol {
    /// Returns an array of actions that are visible in the product form primary section.
    func primarySectionActions() -> [EventFormEditAction]

    /// Returns an array of actions that are visible in the product form settings section.
    func settingsSectionActions() -> [EventFormEditAction]

    /// Returns an array of actions that are visible in the product form bottom sheet.
    func bottomSheetActions() -> [EventFormBottomSheetAction]
}
