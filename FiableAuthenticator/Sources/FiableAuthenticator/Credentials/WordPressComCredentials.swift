import Foundation

// MARK: - WordPress.com Credentials
//
public struct WordPressComCredentials: Equatable {

    /// WordPress.com authentication token
    ///
    public let authToken: String

    /// Is 2-factor Authentication Enabled?
    ///
    public let multifactor: Bool

    /// The site address used during login
    ///
    public var siteURL: String

    private let wpComURL = "https://wordpress.com"

    /// Legacy  initializer, for backwards compatibility
    ///
    public init(authToken: String,
                multifactor: Bool,
                siteURL: String = "https://wordpress.com") {
        self.authToken = authToken
        self.multifactor = multifactor
        self.siteURL = !siteURL.isEmpty ? siteURL : wpComURL
    }
}

// MARK: - Equatable Conformance
//
public func ==(lhs: WordPressComCredentials, rhs: WordPressComCredentials) -> Bool {
    return lhs.authToken == rhs.authToken && lhs.siteURL == rhs.siteURL
}
