import Foundation

// MARK: - FiableAuthenticator Error Constants. Once the entire code is Swifted, let's *PLEASE* have a
//          beautiful Error `Swift Enum`.
//
extension FiableAuthenticator {

    /// Error Domain for Authentication issues.
    ///
    @objc public static let errorDomain = "org.wordpress.ios.authenticator"

    /// "Invalid Version" Error Code. Used whenever the remote WordPress.org endpoint is below the supported version.
    ///
    @objc public static let invalidVersionErrorCode = 5000
}
