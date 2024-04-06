import KeychainAccess

extension Keychain {
    /// The Apple ID that the user signed in to the WooCommerce app via SIWA.
    var wooAppleID: String? {
        get { self[FiableConstants.keychainAppleIDKey] }
        set { self[FiableConstants.keychainAppleIDKey] = newValue }
    }

    /// The anonymous ID used to identify a logged-out user potentially across installs in analytics and A/B experiments.
    var anonymousID: String? {
        get { self[FiableConstants.anonymousIDKey] }
        set { self[FiableConstants.anonymousIDKey] = newValue }
    }

    /// Auth token for the current selected store
    ///
    var currentAuthToken: String? {
        get { self[FiableConstants.authToken] }
        set { self[FiableConstants.authToken] = newValue }
    }

    /// Site credential password of the logged-in user
    ///
    var siteCredentialPassword: String? {
        get { self[FiableConstants.siteCredentialPassword] }
        set { self[FiableConstants.siteCredentialPassword] = newValue }
    }
}
