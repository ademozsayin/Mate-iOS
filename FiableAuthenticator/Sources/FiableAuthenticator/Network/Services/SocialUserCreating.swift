/// A type that can create WordPress.com users given a social users, either coming from Google or Apple.
protocol SocialUserCreating:AnyObject {

    func createWPComUserWithGoogle(
        token: String,
        success: @escaping (_ newAccount: Bool, _ username: String, _ wpcomToken: String) -> Void,
        failure: @escaping (_ error: Error) -> Void
    )

    func createOnsaUserWithApple(
        token: String,
        devicename:String,
        success: @escaping (
            BaseResponse<SignInWithApplePayload>?
        ) -> Void,
        failure: @escaping (_ error: Error) -> Void
    )
}

// MARK: - SignInWithApplePayload
public struct SignInWithApplePayload: Codable {
    public let token: String?
    public let accountCreated: Bool?
    public let user: User?

    enum CodingKeys: String, CodingKey {
        case token = "token"
        case accountCreated = "accountCreated"
        case user = "user"
    }
}

// MARK: - User
public struct User: Codable {
    public let id: Int?
    public let name: String?
    public let email: String?
    public let providerID: String?
    public let provider: String?
    public let emailVerifiedAt: String?
    public let createdAt: String?
    public let updatedAt: String?
    public let magicLinkToken: String?
    public let magicLinkTokenExpiresAt: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case email = "email"
        case providerID = "provider_id"
        case provider = "provider"
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case magicLinkToken = "magic_link_token"
        case magicLinkTokenExpiresAt = "magic_link_token_expires_at"
    }
}
