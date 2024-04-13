//
//  ZendeskManagerProtocol.swift
//  Mate
//
//  Created by Adem Özsayın on 10.04.2024.
//

import Foundation
import SafariServices

/// Defines methods for showing Zendesk UI.
///
/// This is primarily used for testability. Not all methods in `ZendeskManager` are defined but
/// feel free to add them when needed.
///
protocol ZendeskManagerProtocol {
    typealias onUserInformationCompletion = (_ success: Bool, _ email: String?) -> Void

    /// Creates a Zendesk Identity to be able to submit support request tickets given a username and email address.
    /// Throws an error if the identity cannot be created.
    ///
    func createIdentity(name: String, email: String) async throws

    /// Creates a Zendesk Identity to be able to submit support request tickets.
    /// Uses the provided `ViewController` to present an alert for requesting email address when required.
    ///
    func createIdentity(presentIn viewController: UIViewController, completion: @escaping (Bool) -> Void)

    /// Creates a support request using the API-Providers SDK.
    ///
    func createSupportRequest(formID: Int64,
                              customFields: [Int64: String],
                              tags: [String],
                              subject: String,
                              description: String,
                              onCompletion: @escaping (Result<Void, Error>) -> Void)

    var zendeskEnabled: Bool { get }
    var haveUserIdentity: Bool { get }

    /// Returns the user's name and email from saved identity or login credentials.
    ///
    func retrieveUserInfoIfAvailable() -> (name: String?, emailAddress: String?)
    func showHelpCenter(from controller: UIViewController)
    func showSupportEmailPrompt(from controller: UIViewController, completion: @escaping onUserInformationCompletion)
    func initialize()
    func reset()
}

struct NoZendeskManager: ZendeskManagerProtocol {
    func createIdentity(name: String, email: String) async throws {
        // no-op
    }

    func createIdentity(presentIn viewController: UIViewController, completion: @escaping (Bool) -> Void) {
        // no-op
    }

    func createSupportRequest(formID: Int64,
                              customFields: [Int64: String],
                              tags: [String],
                              subject: String,
                              description: String,
                              onCompletion: @escaping (Result<Void, Error>) -> Void) {
        // no-op
    }

    let zendeskEnabled = false

    let haveUserIdentity = false

    func retrieveUserInfoIfAvailable() -> (name: String?, emailAddress: String?) {
        return (nil, nil)
    }

    func showHelpCenter(from controller: UIViewController) {
        // no-op
    }

    func showSupportEmailPrompt(from controller: UIViewController, completion: @escaping onUserInformationCompletion) {
        // no-op
    }

    func initialize() {
        // no-op
    }

    func reset() {
        // no-op
    }
}

struct ZendeskProvider {
    /// Shared Instance
    ///
    #if !targetEnvironment(macCatalyst)
   // static let shared: ZendeskManagerProtocol = ZendeskManager()
    static let shared: ZendeskManagerProtocol = NoZendeskManager()
    #else
    static let shared: ZendeskManagerProtocol = NoZendeskManager()
    #endif
}


/// This class provides the functionality to communicate with Zendesk for Help Center and support ticket interaction,
/// as well as displaying views for the Help Center, new tickets, and ticket list.
///
#if !targetEnvironment(macCatalyst)
final class ZendeskManager: NSObject {
//final class ZendeskManager: NSObject, ZendeskManagerProtocol {
    /// Indicates if Zendesk is Enabled (or not)
    ///
    private (set) var zendeskEnabled = false {
        didSet {
            DDLogInfo("Zendesk Enabled: \(zendeskEnabled)")
        }
    }

    // MARK: - Private Properties
    //
    private var userName: String?
    private var userEmail: String?
    private(set) var haveUserIdentity = false
    private var alertNameField: UITextField?

    private weak var presentInController: UIViewController?

    // MARK: - Public Methods


    /// Sets up the Zendesk Manager instance
    ///
    func initialize() {
        guard zendeskEnabled == false else {
            DDLogError("☎️ Zendesk was already Initialized!")
            return
        }
        
    }

}

// MARK: - Private Extension
//
private extension ZendeskManager {

}


// MARK: - Nested Types
//
private extension ZendeskManager {

    // MARK: - Constants
    //
    struct Constants {
        static let profileEmailKey = "email"
        static let profileNameKey = "name"
        static let nameFieldCharacterLimit = 50
        static let zendeskProfileUDKey = "wc_zendesk_profile"
    }

    struct LocalizedText {
        static let alertMessageWithName = NSLocalizedString(
            "Please enter your email address and username:",
            comment: "Instructions for alert asking for email and name."
        )
        static let alertMessage = NSLocalizedString(
            "Please enter your email address:",
            comment: "Instructions for alert asking for email."
        )
        static let alertSubmit = NSLocalizedString(
            "OK",
            comment: "Submit button on prompt for user information."
        )
        static let alertCancel = NSLocalizedString(
            "Cancel",
            comment: "Cancel prompt for user information."
        )
        static let emailPlaceholder = NSLocalizedString(
            "Email",
            comment: "Email address text field placeholder"
        )
        static let namePlaceholder = NSLocalizedString(
            "Name",
            comment: "Name text field placeholder"
        )
    }
}

// MARK: - UITextFieldDelegate
//
extension ZendeskManager: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == alertNameField,
            let text = textField.text else {
                return true
        }

        let newLength = text.count + string.count - range.length
        return newLength <= Constants.nameFieldCharacterLimit
    }
}
#endif

enum ZendeskError: Error {
    case failedToCreateIdentity
}
