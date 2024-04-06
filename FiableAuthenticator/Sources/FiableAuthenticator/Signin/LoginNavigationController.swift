import UIKit
import FiableShared
import FiableUI

public class LoginNavigationController: RotationAwareNavigationViewController {

    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? FiableAuthenticator.shared.style.statusBarStyle
    }

    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        // By default, the back button label uses the previous view's title.
        // To override that, reset the label when pushing a new view controller.
        if #available(iOS 14.0, *) {
            self.viewControllers.last?.navigationItem.backButtonDisplayMode = .minimal
        } else {
            self.viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(), style: .plain, target: nil, action: nil)
        }

        super.pushViewController(viewController, animated: animated)
    }

}
