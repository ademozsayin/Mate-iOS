//
//  GeneralAppSettings.swift
//  Storage
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Foundation
import CodeGen

/// An encodable/decodable data structure that can be used to save files. This contains
/// miscellaneous app settings.
///
/// Sometimes I wonder if `AppSettingsStore` should just use one plist file. Maybe things will
/// be simpler?
///
public struct GeneralAppSettings: Codable, Equatable, GeneratedCopiable {
    /// The known `Date` that the app was installed.
    ///
    /// Note that this is not accurate because this property/setting was created when we have
    /// thousands of users already.
    ///
    public var installationDate: Date?

    public var localAnnouncementDismissed: [LocalAnnouncement: Bool]

    public init(installationDate: Date?,
                localAnnouncementDismissed: [LocalAnnouncement: Bool]) {
        self.installationDate = installationDate
        self.localAnnouncementDismissed = localAnnouncementDismissed
    }

    public static var `default`: Self {
        .init(installationDate: nil,
              localAnnouncementDismissed: [:])
    }

    /// Returns the status of a given feedback type. If the feedback is not stored in the feedback array. it is assumed that it has a pending status.
    ///
//    public func feedbackStatus(of type: FeedbackType) -> FeedbackSettings.Status {
//        guard let feedbackSetting = feedbacks[type] else {
//            return .pending
//        }
//
//        return feedbackSetting.status
//    }

    /// Returns a new instance of `GeneralAppSettings` with the provided feedback seetings updated.
    ///
//    public func replacing(feedback: FeedbackSettings) -> GeneralAppSettings {
//        let updatedFeedbacks = feedbacks.merging([feedback.name: feedback]) {
//            _, new in new
//        }
//
//        return GeneralAppSettings(
//            installationDate: installationDate,
//            localAnnouncementDismissed: localAnnouncementDismissed
//        )
//    }

    /// Returns a new instance of `GeneralAppSettings` with the provided feature announcement campaign seetings updated.
    ///
//    public func replacing(featureAnnouncementSettings: FeatureAnnouncementCampaignSettings, for campaign: FeatureAnnouncementCampaign) -> GeneralAppSettings {
//        let updatedSettings = featureAnnouncementCampaignSettings.merging([campaign: featureAnnouncementSettings]) {
//            _, new in new
//        }
//
//        return GeneralAppSettings(
//            installationDate: installationDate,
//            localAnnouncementDismissed: localAnnouncementDismissed
//        )
//    }

    /// Returns a new instance of `GeneralAppSettings` with the provided feature announcement campaign seetings updated.
    ///
    public func updatingAsDismissed(localAnnouncement: LocalAnnouncement) -> GeneralAppSettings {
        let updatedSettings = localAnnouncementDismissed.merging([localAnnouncement: true]) {
            _, new in new
        }

        return GeneralAppSettings(
            installationDate: installationDate,
            localAnnouncementDismissed: updatedSettings
        )
    }
}

// MARK: Custom Decoding
extension GeneralAppSettings {
    /// We need a custom decoding to make sure it doesn't fails when this type is updated (eg: when adding/removing new properties)
    /// Otherwise we will lose previously stored information.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.installationDate = try container.decodeIfPresent(Date.self, forKey: .installationDate)
        self.localAnnouncementDismissed = try container.decodeIfPresent([LocalAnnouncement: Bool].self,
                                                                        forKey: .localAnnouncementDismissed) ?? [:]

        // Decode new properties with `decodeIfPresent` and provide a default value if necessary.
    }
}

public enum LocalAnnouncement: Codable, Equatable {
    case productDescriptionAI
}
