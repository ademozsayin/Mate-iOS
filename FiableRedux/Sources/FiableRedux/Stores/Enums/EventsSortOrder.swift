//
//  EventsSortOrder.swift
//
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation

public enum EventsSortOrder: String {
    // From the newest to the oldest
    case dateDescending
    // From the oldest to the newest
    case dateAscending
    // Product name from Z to A
    case nameDescending
    // Product name from A to Z
    case nameAscending

    public static let `default`: EventsSortOrder = .nameAscending
}
