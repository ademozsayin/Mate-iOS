//
//  DotcomRequest.swift
//  Networking
//
//  Created by Adem Özsayın on 25.03.2024.
//

import Foundation
import Alamofire


enum DotcomRequestError: Error {
    case apiVersionCannotBeAccessedUsingRESTAPI
}

/// Represents a WordPress.com Request
///
struct DotcomRequest: Request, RESTRequestConvertible {

    /// HTTP Request Method
    ///
    let method: HTTPMethod

    /// RPC
    ///
    let path: String

    /// Parameters
    ///
    let parameters: [String: Any]?

    /// HTTP Headers
    let headers: [String: String]

    /// Allows custom encoding for the parameters.
    private let encoding: ParameterEncoding

    /// Whether this request should be transformed to a REST request if application password is available.
    ///
    private let availableAsRESTRequest: Bool

    /// Initializer.
    ///
    /// - Parameters:
    ///     - wordpressApiVersion: Endpoint Version.
    ///     - method: HTTP Method we should use.
    ///     - path: RPC that should be executed.
    ///     - parameters: Collection of String parameters to be passed over to our target RPC.
    ///     - headers: Headers used in the URLRequest
    ///     - encoding: How the parameters are encoded. Default to use `URLEncoding`.
    ///
    init(
        method: HTTPMethod,
         path: String,
         parameters: [String: Any]? = nil,
         headers: [String: String]? = nil,
         encoding: ParameterEncoding = URLEncoding.default
    ) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.headers = headers ?? [:]
        self.encoding = encoding
        self.availableAsRESTRequest = false
    }

    /// Initializer.
    ///
    /// - Parameters:
    ///     - wordpressApiVersion: Endpoint Version.
    ///     - method: HTTP Method we should use.
    ///     - path: RPC that should be executed.
    ///     - parameters: Collection of String parameters to be passed over to our target RPC.
    ///     - headers: Headers used in the URLRequest
    ///     - encoding: How the parameters are encoded. Default to use `URLEncoding`.
    ///     - availableAsRESTRequest: Whether the request should be transformed to a REST request if application password is available.
    ///
    init(
         method: HTTPMethod,
         path: String,
         parameters: [String: Any]? = nil,
         headers: [String: String]? = nil,
         encoding: ParameterEncoding = URLEncoding.default,
         availableAsRESTRequest: Bool) throws {
        if availableAsRESTRequest {
            throw DotcomRequestError.apiVersionCannotBeAccessedUsingRESTAPI
        }

        self.method = method
        self.path = path
        self.parameters = parameters
        self.headers = headers ?? [:]
        self.encoding = encoding
        self.availableAsRESTRequest = availableAsRESTRequest
    }

    /// Returns a URLRequest instance representing the current WordPress.com Request.
    ///
    func asURLRequest() throws -> URLRequest {
        let dotcomURL = URL(string: Settings.onsaApiBaseURL + path)!
        let dotcomRequest = try URLRequest(url: dotcomURL, method: method, headers: .init(headers))
        return try encoding.encode(dotcomRequest, with: parameters)
    }

    func responseDataValidator() -> ResponseDataValidator {
//        switch wordpressApiVersion {
//        case .mark1_1, .mark1_2, .mark1_3, .mark1_5:
//            return DotcomValidator()
//        case .wpcomMark2, .wpMark2:
//            return WordPressApiValidator()
//        }
        return DotcomValidator()
    }

    func asRESTRequest(with siteURL: String) -> RESTRequest? {
        guard availableAsRESTRequest else {
            return nil
        }

//        guard wordpressApiVersion.isWPOrgEndpoint else {
//            return nil
//        }

        // As the REST request is directly sent to the site URL, we remove site info from path
        guard let pathWithoutSiteInfo = try? pathAfterRemovingSitesComponent() else {
            return nil
        }

        return RESTRequest(siteURL: siteURL,
                           wooApiVersion: .none,
                           method: method,
                           path: pathWithoutSiteInfo,
                           parameters: parameters)
    }
}

private extension DotcomRequest {
    /// Removes the site info from the `path`
    ///
    /// - Returns: Path without `sites/$siteID/`
    ///
    func pathAfterRemovingSitesComponent() throws -> String {
        let regex = try NSRegularExpression(pattern: "([\\/]*sites\\/.[^\\/]*\\/)")
        let range = NSRange(location: 0, length: path.count)
        return regex.stringByReplacingMatches(in: path, range: range, withTemplate: "")
    }
}
