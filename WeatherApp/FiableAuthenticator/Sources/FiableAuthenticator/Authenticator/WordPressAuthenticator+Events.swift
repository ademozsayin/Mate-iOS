import Foundation
import FiableShared

// MARK: - Authentication Flow Event. Useful to relay internal Auth events over to activity trackers.
//
extension FiableAuthenticator {

    /// Tracks the specified event.
    ///
//    @objc
    public static func track(_ event: FiableAnalyticsStat) {
        FiableAuthenticator.shared.delegate?.track(event: event)
    }

    /// Tracks the specified event, with the specified properties.
    ///
//    @objc
    public static func track(_ event: FiableAnalyticsStat, properties: [AnyHashable: Any]) {
        FiableAuthenticator.shared.delegate?.track(event: event, properties: properties)
    }

    /// Tracks the specified event, with the associated Error.
    ///
    /// Note: Ideally speaking... `Error` is not optional. *However* this method is to be used in the ObjC realm, where not everything
    /// has it's nullability specifier set. We're just covering unexpected scenarios.
    ///
//    @objc
    public static func track(_ event: FiableAnalyticsStat, error: Error?) {
        guard let error = error else {
            track(event)
            return
        }

        FiableAuthenticator.shared.delegate?.track(event: event, error: error)
    }
}
