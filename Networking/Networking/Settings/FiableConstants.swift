//
//  FiableConstants.swift
//  Networking
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Foundation

/// Constants to be shared in Networking layer.
///
public enum FiableConstants {
    /// Placeholder site ID to be used when the user is logged in without WPCom.
    public static let placeholderSiteID: Int64 = -1

    /// Keychain Access's Service Name
    ///
    public static let keychainServiceName = "app.fiable.WeatherApp"

    /// Slug of the free plan
    static let freePlanSlug = "free_plan"

    /// Slug of the free trial WooExpress plan
    static let freeTrialPlanSlug = "ecommerce-trial-bundle-monthly"
}
