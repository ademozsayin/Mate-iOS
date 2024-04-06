//
//  OnsaAnalyticsEvent+LoginOnboarding.swift
//  Mate
//
//  Created by Adem Özsayın on 23.03.2024.
//
//import FiableShared

extension FiableAnalyticsEvent {
    enum LoginOnboarding {
        /// Event property keys.
        private enum Keys {
            static let isFinalFeaturePage = "is_final_page"
        }

        /// Tracked when login onboarding is shown in the app.
        static func loginOnboardingShown() -> FiableAnalyticsEvent {
            FiableAnalyticsEvent(statName: .loginOnboardingShown, properties: [:])
        }

        /// Tracked when the user taps on the “Next” button on the login onboarding screen to see the next app feature or continue to the prologue screen.
        /// - Parameter isFinalPage: whether the user taps the “Next” button on the final page of the feature.
        static func loginOnboardingNextButtonTapped(isFinalPage: Bool) -> FiableAnalyticsEvent {
            FiableAnalyticsEvent(statName: .loginOnboardingNextButtonTapped, properties: [Keys.isFinalFeaturePage: isFinalPage])
        }

        /// Tracked when the user taps on the “Skip” button on the login onboarding screen to enter the prologue screen.
        static func loginOnboardingSkipButtonTapped() -> FiableAnalyticsEvent {
            FiableAnalyticsEvent(statName: .loginOnboardingSkipButtonTapped, properties: [:])
        }
    }
}
