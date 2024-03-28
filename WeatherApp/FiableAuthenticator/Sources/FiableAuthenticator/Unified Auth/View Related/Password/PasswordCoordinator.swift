/// Coordinates the navigation after entering WP.com username.
/// Based on the configuration, it could automatically send a magic link and proceed the magic link requested screen on success and fall back to password.

import UIKit
@MainActor
final class PasswordCoordinator {
    private weak var navigationController: UINavigationController?
    private let source: SignInSource?
    private let loginFields: LoginFields
    private let tracker: AuthenticatorAnalyticsTracker
    private let configuration: FiableAuthenticatorConfiguration

    init(navigationController: UINavigationController,
         source: SignInSource?,
         loginFields: LoginFields,
         tracker: AuthenticatorAnalyticsTracker,
         configuration: FiableAuthenticatorConfiguration) {
        self.navigationController = navigationController
        self.source = source
        self.loginFields = loginFields
        self.tracker = tracker
        self.configuration = configuration
    }

    func start()  {
        showPassword()
    }
}

private extension PasswordCoordinator {

    /// Navigates the user to enter WP.com password.
    func showPassword() {
        guard let vc = PasswordViewController.instantiate(from: .password) else {
            return print("Failed to navigate to PasswordViewController from GetStartedViewController")
        }

        vc.source = source
        vc.loginFields = loginFields
        vc.trackAsPasswordChallenge = false

        navigationController?.pushViewController(vc, animated: true)
    }
}
