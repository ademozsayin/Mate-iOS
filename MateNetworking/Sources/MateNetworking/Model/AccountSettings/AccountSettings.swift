//
//  AccountSettings.swift
//
//
//  Created by Adem Özsayın on 6.04.2024.
//

import Foundation
import CodeGen

///
public struct AccountSettings: Decodable, Equatable, GeneratedFakeable {

    /// Dotcom UserID
    ///
    public let userID: Int64

    /// Tracks analytics opt out dotcom setting
    ///
    public let tracksOptOut: Bool

    /// First name of the Account
    ///
    public let name: String?

    /// Default initializer for AccountSettings.
    ///
    public init(userID: Int64, tracksOptOut: Bool, name: String?) {
        self.userID = userID
        self.tracksOptOut = tracksOptOut
        self.name = name
    }


    /// The public initializer for AccountSettings.
    ///
    public init(from decoder: Decoder) throws {
        guard let userID = decoder.userInfo[.userID] as? Int64 else {
            throw AccountSettingsDecodingError.missingUserID
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        let tracksOptOut = try container.decode(Bool.self, forKey: .tracksOptOut)
        let name = try container.decodeIfPresent(String.self, forKey: .name)

        self.init(userID: userID, tracksOptOut: tracksOptOut, name: name)
    }
}


/// Defines all of the AccountSettings CodingKeys
///
private extension AccountSettings {

    enum CodingKeys: String, CodingKey {
        case userID         = "id"
        case tracksOptOut   = "tracks_opt_out"
        case name
       
    }
}


// MARK: - Decoding Errors
//
enum AccountSettingsDecodingError: Error {
    case missingUserID
}
