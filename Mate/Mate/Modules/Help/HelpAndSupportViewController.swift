import UIKit
import FiableRedux
import FiableAuthenticator
// MARK: - HelpAndSupportViewController
//
final class HelpAndSupportViewController: UIViewController {

    /// Main TableView
    ///
    @IBOutlet private weak var tableView: UITableView!

    /// Table Sections to be rendered
    ///
    private var sections = [Section]()

    /// User's preferred email for support messages
    ///
    private var accountEmail: String {
        // A stored Zendesk email address is preferred
        if let zendeskEmail = ZendeskProvider.shared.retrieveUserInfoIfAvailable().emailAddress {
            return zendeskEmail
        }

        // If no preferred ZD email exists, try the account email
        if let mainEmail = ServiceLocator.stores.sessionManager.defaultAccount?.email {
            return mainEmail
        }

        // If that doesn't exist, indicate we need them to set an email.
        return NSLocalizedString("Set email", comment: "Tells user to set an email that support can use for replies")
    }

    /// Indicates if the NavBar should display a dismiss button
    ///
    var displaysDismissAction = false

    /// Custom help center web page related properties
    /// If non-nil this web page is launched instead of Zendesk
    ///
    private let customHelpCenterContent: CustomHelpCenterContent?

    /// Source tag from where this request was originated.
    ///
    private let sourceTag: String?

    init?(customHelpCenterContent: CustomHelpCenterContent, sourceTag: String? = nil, coder: NSCoder) {
        self.customHelpCenterContent = customHelpCenterContent
        self.sourceTag = sourceTag
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        self.customHelpCenterContent = nil
        self.sourceTag = nil
        super.init(coder: coder)
    }

    // MARK: - Overridden Methods
    //
    override func viewDidLoad() {
        super.viewDidLoad()

        configureNavigation()
        configureMainView()
        configureSections()
        configureTableView()
        registerTableViewCells()
//        configureResultsControllers { [weak self] in
//            self?.refreshViewContent()
//        }
        refreshViewContent()
//        warnDeveloperIfNeeded()
       
    }
}

// MARK: - View Configuration
//
private extension HelpAndSupportViewController {

    /// Set the title and back button.
    ///
    func configureNavigation() {
        title = NSLocalizedString("Help", comment: "Help and Support navigation title")

        // Dismiss
        navigationItem.leftBarButtonItem = {
            guard displaysDismissAction else {
                return nil
            }

            let title = NSLocalizedString("Dismiss", comment: "Add a note screen - button title for closing the view")
            return UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(dismissWasPressed))
        }()
    }

    /// Apply Woo styles.
    ///
    func configureMainView() {
        view.backgroundColor = .listBackground
    }

    /// Configure common table properties.
    ///
    func configureTableView() {
        tableView.estimatedRowHeight = Constants.rowHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .listBackground
    }
    /// Disable Zendesk if configuration on ZD init fails.
    ///
    func configureSections() {
        let helpAndSupportTitle = NSLocalizedString("HOW CAN WE HELP?", comment: "My Store > Settings > Help & Support section title")
        #if !targetEnvironment(macCatalyst)
//        guard ZendeskProvider.shared.zendeskEnabled == true else {
//            sections = [Section(title: helpAndSupportTitle, rows: [.helpCenter])]
//            return
//        }

        sections = [
            Section(title: helpAndSupportTitle, rows: calculateRows())
        ]
        #else
        sections = [Section(title: helpAndSupportTitle, rows: [.helpCenter])]
        #endif
                
    }

    private func calculateRows() -> [Row] {
//        var rows: [Row] = [.helpCenter, .contactSupport]
        var rows: [Row] = [ .contactSupport]

        rows.append(contentsOf: [.contactEmail,
                                 .applicationLog,
                                 .systemStatusReport])
        return rows
    }

    /// Register table cells.
    ///
    func registerTableViewCells() {
        for row in Row.allCases {
            tableView.registerNib(for: row.type)
        }
    }

//    /// Warn devs that logged in with an Automattic email.
//    ///
//    func warnDeveloperIfNeeded() {
//        let developerEmailChecker = DeveloperEmailChecker()
//        guard developerEmailChecker.isDeveloperEmail(email: accountEmail) else {
//            return
//        }
//
//        let alert = UIAlertController(title: "Warning",
//                                      message: "Developer email account detected. Please log in with a non-Automattic email to submit or view support tickets.",
//                                      preferredStyle: .alert)
//        let cancel = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
//        alert.addAction(cancel)
//
//        present(alert, animated: true, completion: nil)
//    }

    /// Cells currently configured in the order they appear on screen
    ///
    func configure(_ cell: UITableViewCell, for row: Row, at indexPath: IndexPath) {
        switch cell {
        case let cell as ValueOneTableViewCell where row == .helpCenter:
            configureHelpCenter(cell: cell)
        case let cell as ValueOneTableViewCell where row == .contactSupport:
            configureContactSupport(cell: cell)
        case let cell as ValueOneTableViewCell where row == .contactEmail:
            configureMyContactEmail(cell: cell)
        case let cell as ValueOneTableViewCell where row == .applicationLog:
            configureApplicationLog(cell: cell)
        case let cell as ValueOneTableViewCell where row == .systemStatusReport:
            configureSystemStatusReport(cell: cell)
        default:
            fatalError()
        }
    }

    /// Help Center cell.
    ///
    func configureHelpCenter(cell: ValueOneTableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.text = NSLocalizedString("Help Center", comment: "Browse our help documentation website title")
        cell.detailTextLabel?.text = NSLocalizedString("Get answers to questions you have", comment: "Subtitle for Help Center")
    }

    /// Contact Support cell.
    ///
    func configureContactSupport(cell: ValueOneTableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.text = NSLocalizedString("Contact Support", comment: "Contact Support title")
        cell.detailTextLabel?.text = NSLocalizedString(
            "Reach our happiness engineers who can help answer tough questions",
            comment: "Subtitle for Contact Support"
        )
    }

    /// Contact Email cell.
    ///
    func configureMyContactEmail(cell: ValueOneTableViewCell) {
        cell.selectionStyle = .none
        cell.textLabel?.text = NSLocalizedString("Contact Email", comment: "Contact Email title")
        cell.detailTextLabel?.text = accountEmail
        cell.accessoryType = .none

    }

    /// Application Log cell.
    ///
    func configureApplicationLog(cell: ValueOneTableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.text = NSLocalizedString("View Application Log", comment: "View application log cell title")
        cell.detailTextLabel?.text = NSLocalizedString(
            "Advanced tool to review the app status",
            comment: "Cell subtitle explaining why you might want to navigate to view the application log."
        )
    }

    /// System Status Report cell
    ///
    func configureSystemStatusReport(cell: ValueOneTableViewCell) {
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        cell.textLabel?.text = NSLocalizedString("System Status Report", comment: "View system status report cell title on Help screen")
        cell.detailTextLabel?.text = NSLocalizedString(
            "Various system information about your site",
            comment: "Description of the system status report on Help screen"
        )
    }

    func refreshViewContent() {
        configureSections()
        tableView.reloadData()
    }
}


// MARK: - Convenience Methods
//
private extension HelpAndSupportViewController {

    func rowAtIndexPath(_ indexPath: IndexPath) -> Row {
        return sections[indexPath.section].rows[indexPath.row]
    }

    /// Opens custom help center URL in a web view
    ///
    func launchCustomHelpCenterWebPage(_ customHelpCenterContent: CustomHelpCenterContent) {
        WebviewHelper.launch(customHelpCenterContent.url, with: self)

        ServiceLocator.analytics.track(.supportHelpCenterViewed,
                                       withProperties: customHelpCenterContent.trackingProperties)
    }
}

// MARK: - Actions
//
private extension HelpAndSupportViewController {

    /// Help Center action
    ///
    func helpCenterWasPressed() {
        if let customHelpCenterContent = customHelpCenterContent {
            launchCustomHelpCenterWebPage(customHelpCenterContent)
        } else {
            ZendeskProvider.shared.showHelpCenter(from: self)
        }
    }

    /// Contact Support action
    ///
    func contactSupportWasPressed() {
        let viewController = SupportFormHostingController(viewModel: .init(sourceTag: sourceTag))
        viewController.show(from: self)
    }

    /// User's contact email action
    ///
    func contactEmailWasPressed() {
        guard let navController = navigationController else {
            return
        }

        ZendeskProvider.shared.showSupportEmailPrompt(from: navController) { [weak self] (success, email) in
            guard success else {
                return
            }

            guard let self = self else {
                return
            }

//            self.warnDeveloperIfNeeded()

            // Tracking when the dialog's "OK" button is pressed, not necessarily if the value changed.
            ServiceLocator.analytics.track(.supportIdentitySet)
            self.tableView.reloadData()
        }
    }

    /// View application log action
    ///
    func applicationLogWasPressed() {
        let identifier = ApplicationLogViewController.classNameWithoutNamespaces
        guard let applicationLogVC = UIStoryboard.dashboard.instantiateViewController(identifier: identifier) as? ApplicationLogViewController else {
            DDLogError("Error: attempted to instantiate ApplicationLogViewController. Instantiation failed.")
            return
        }
        navigationController?.pushViewController(applicationLogVC, animated: true)
    }

    /// System status report action
    ///
    func systemStatusReportWasPressed() {
//        guard let siteID = ServiceLocator.stores.sessionManager.defaultStoreID else {
//            return
//        }
        let controller = SystemStatusReportHostingController(siteID: 1)
        controller.hidesBottomBarWhenPushed = true
        controller.setDismissAction { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
        ServiceLocator.analytics.track(.supportSSROpened)
    }

    @objc func dismissWasPressed() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource Conformance
//
extension HelpAndSupportViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rowAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.reuseIdentifier, for: indexPath)
        configure(cell, for: row, at: indexPath)

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}

// MARK: - UITableViewDelegate Conformance
//
extension HelpAndSupportViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        switch rowAtIndexPath(indexPath) {
        case .helpCenter:
            helpCenterWasPressed()
        case .contactSupport:
            contactSupportWasPressed()
        case .contactEmail:
            contactEmailWasPressed()
        case .applicationLog:
            applicationLogWasPressed()
        case .systemStatusReport:
            systemStatusReportWasPressed()
        }
    }
}


// MARK: - Private Types
//
private struct Constants {
    static let rowHeight = CGFloat(44)
    static let footerHeight = 44
}

private struct Section {
    let title: String?
    let rows: [Row]
}

private enum Row: CaseIterable {
    case helpCenter
    case contactSupport
    case contactEmail
    case applicationLog
    case systemStatusReport

    var type: UITableViewCell.Type {
        switch self {
        case .helpCenter:
            return ValueOneTableViewCell.self
        case .contactSupport:
            return ValueOneTableViewCell.self
        case .contactEmail:
            return ValueOneTableViewCell.self
        case .applicationLog:
            return ValueOneTableViewCell.self
        case .systemStatusReport:
            return ValueOneTableViewCell.self
        }
    }

    var reuseIdentifier: String {
        return type.reuseIdentifier
    }
}


struct CustomHelpCenterContent {
    /// Custom help center web page's URL
    ///
    let url: URL

    /// Provides a dictionary for analytics tracking
    ///
    let trackingProperties: [String: String]

    /// Used for tracking analytics events
    ///
    enum Key: String {
        case step = "source_step"
        case flow = "source_flow"
        case url = "help_content_url"
    }
}

// MARK: Initializer for WordPressAuthenticator screens
//
extension CustomHelpCenterContent {
    /// Initializes a `CustomHelpCenterContent` instance using `Step` and `Flow` from `AuthenticatorAnalyticsTracker`
    ///
    init?(step: AuthenticatorAnalyticsTracker.Step, flow: AuthenticatorAnalyticsTracker.Flow) {
        switch step {
        case .start where flow == .loginWithSiteAddress: // Enter Store Address screen
            url = FiableConstants.URLs.helpCenterForEnterStoreAddress.asURL()
        case .enterEmailAddress where flow == .loginWithSiteAddress: // Enter WordPress.com email screen from store address flow
            url = FiableConstants.URLs.helpCenterForWPCOMEmailFromSiteAddressFlow.asURL()
        case .enterEmailAddress where flow == .wpCom: // Enter WordPress.com email screen from store WPCOM email flow
            url = FiableConstants.URLs.helpCenterForWPCOMEmailScreen.asURL()
        case .usernamePassword: // Enter Store credentials screen (wp-admin creds)
            url = FiableConstants.URLs.helpCenterForEnterStoreCredentials.asURL()
        // Enter WordPress.com password screen
        case .start where (flow == .loginWithPasswordWithMagicLinkEmphasis || flow == .loginWithPassword),
                .passwordChallenge: // Password challenge when logging in using social account
            url = FiableConstants.URLs.helpCenterForWPCOMPasswordScreen.asURL()
        case .magicLinkAutoRequested, .magicLinkRequested: // Open magic link from email screen
            url = FiableConstants.URLs.helpCenterForOpenEmail.asURL()
        default:
            return nil
        }

        trackingProperties = [
            Key.step.rawValue: step.rawValue,
            Key.flow.rawValue: flow.rawValue,
            Key.url.rawValue: url.absoluteString
        ]
    }
}

// MARK: Initializer for WCiOS screens
//
extension CustomHelpCenterContent {
    /// Screens related to login/authentication
    ///  These screens are from WCiOS codebase and they don't exist in WordPressAuthenticator library
    ///
    enum Screen {
        /// Jetpack required error screen presented using `JetpackErrorViewModel`
        ///
        case jetpackRequired

        /// Store picker screen - `StorePickerViewController`
        ///
        case storePicker

        /// Account mismatch / Wrong WordPress.com account screen - `WrongAccountErrorViewModel`
        ///
        case wrongAccountError

        /// No WooCommerce site error  using `NoWooErrorViewModel`
        ///
        case noWooError

        /// The merchant is dealing with an error while they're purchasing a plan.
        case purchasePlanError
    }

    init(screen: Screen, flow: AuthenticatorAnalyticsTracker.Flow) {
        let step: String
        switch screen {
        case .jetpackRequired:
            step = "jetpack_not_connected" // Matching Android `Step` value
            url = FiableConstants.URLs.helpCenterForJetpackRequiredError.asURL()
        case .storePicker:
            step = "site_list" // Matching Android `Step` value
            url = FiableConstants.URLs.helpCenterForStorePicker.asURL()
        case .wrongAccountError:
            step = "wrong_wordpress_account" // Matching Android `Step` value
            url = FiableConstants.URLs.helpCenterForWrongAccountError.asURL()
        case .noWooError:
            step = "not_woo_store" // Matching Android `Step` value
            url = FiableConstants.URLs.helpCenterForNoWooError.asURL()
        case .purchasePlanError:
            step = "purchase_plan_error"
            url = FiableConstants.URLs.helpCenter.asURL()
        }

        trackingProperties = [
            Key.step.rawValue: step,
            Key.flow.rawValue: flow.rawValue,
            Key.url.rawValue: url.absoluteString
        ]
    }
}
