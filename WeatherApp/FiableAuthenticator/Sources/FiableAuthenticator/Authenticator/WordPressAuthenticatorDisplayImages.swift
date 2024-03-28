// MARK: - WordPress Authenticator Display Images
//

import UIKit

public struct FiableAuthenticatorDisplayImages {
    public let magicLink: UIImage
    public let siteAddressModalPlaceholder: UIImage

    /// Designated initializer.
    ///
    public init(magicLink: UIImage, siteAddressModalPlaceholder: UIImage) {
        self.magicLink = magicLink
        self.siteAddressModalPlaceholder = siteAddressModalPlaceholder
    }
}

public extension FiableAuthenticatorDisplayImages {
    static var defaultImages: FiableAuthenticatorDisplayImages {
        return FiableAuthenticatorDisplayImages(
            magicLink: .magicLinkImage,
            siteAddressModalPlaceholder: .siteAddressModalPlaceholder
        )
    }
}
