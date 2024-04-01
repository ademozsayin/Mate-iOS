//
//  OnsaApiRequest.swift
//  Networking
//
//  Created by Adem Özsayın on 1.04.2024.
//


import Foundation
import Alamofire


/// Represents a Jetpack-Tunneled WordPress.com Endpoint
///
struct OnsaApiRequest: Request, RESTRequestConvertible {

    /// Jetpack-Tunneled HTTP Request Method
    ///
    let method: HTTPMethod

    /// Locale identifier, simplified as `language_Region` e.g. `en_US`
    ///
    let locale: String?

    /// Jetpack-Tunneled RPC
    ///
    let path: String

    /// Allows custom encoding for the parameters.
    private let encoding: ParameterEncoding
    
    /// Jetpack-Tunneled Parameters
    ///
    let parameters: [String: Any]

    /// Designated Initializer.
    ///
    /// - Parameters:
    ///     - wooApiVersion: Version of the Woo Endpoint that will be hit.
    ///     - method: HTTP Method we should use.
    ///     - siteID: Identifier of the Jetpack-Connected site we'll query.
    ///     - path: RPC that should be called.
    ///     - parameters: Collection of Key/Value parameters, to be forwarded to the Jetpack Connected site.
    ///     - availableAsRESTRequest: Whether the request should be transformed to a REST request if application password is available.
    ///
    init(
        method: HTTPMethod,
        locale: String? = nil,
        path: String,
        parameters: [String: Any]? = nil,
        encoding: ParameterEncoding = URLEncoding.default
    ){
        self.method = method
        self.locale = locale
        self.path = path
        self.parameters = parameters ?? [:]
        self.encoding = encoding
    }


    /// Returns a URLRequest instance reprensenting the current Jetpack Request.
    ///
    func asURLRequest() throws -> URLRequest {
        let onsastradaCustomFiableUrl =  onsaApiPath + path
        let fiableEndpoint = DotcomRequest(method: onsaMethod, path: onsastradaCustomFiableUrl)
        let fiableRequest = try fiableEndpoint.asURLRequest()

        return try onsaEncoder.encode(fiableRequest, with: parameters)

    }

    func responseDataValidator() -> ResponseDataValidator {
        return OnsaApiValidator()
    }

    func asRESTRequest(with siteURL: String) -> RESTRequest? {
        return RESTRequest(siteURL: siteURL, wooApiVersion: .mark4, method: method, path: path, parameters: parameters)
    }
}


// MARK: - Dotcom Request: Internal
//
private extension OnsaApiRequest {

    /// Returns the WordPress.com Tunneling Request
    ///
    var onsaApiPath: String {
        return "fiableapi/"
    }

    /// Returns the WordPress.com Parameters Encoder
//    ///
    var onsaEncoder: ParameterEncoding {
//        return dotcomMethod == .get ? URLEncoding.queryString : URLEncoding.httpBody
        return onsaMethod == .get ? URLEncoding.default : JSONEncoding.default
//
//        switch fiableMethod {
//        case .post, .put:
//            return JSONEncoding.default
//        default:
//            return URLEncoding.default
//        }

    }

    /// Returns the WordPress.com HTTP Method
    ///
    var onsaMethod: HTTPMethod {
        // If we are calling DELETE via a tunneled connection, use GET instead (DELETE will be added to the `_method` query string param)
        // Likewise, PUT requests should be sent as POST for the tunneled request
        switch method {
        case .get, .delete:
            return .get
        case .post, .put:
            return .post
        default:
            return method
        }
    }

    /// Returns the WordPress.com Parameters
    ///
    var onsaParams: [String: String] {
        var output:[String:String] = [:
//            "json": "true",
//            "path": jetpackPath + "&_method=" + method.rawValue.lowercased()
        ]

        if let locale = locale {
            output["locale"] = locale
        }

        if let onsaQueryParams = onsaQueryParams {
            output["query"] = onsaQueryParams
        }

        if let onsaBodyParams = onsaBodyParams {
            output["body"] = onsaBodyParams
        }

        return output
    }
}


// MARK: - Jetpack Tunneled Request: Internal
//
private extension OnsaApiRequest {

    /// Returns the Jetpack-Tunneled-Request's Path
    ///
    var onsaPath: String {
        return  path
    }

    /// Indicates if the Jetpack Tunneled Request should encode it's parameters in the Query (or Body)
    ///
    var onsaEncodesParametersInQuery: Bool {
        return onsaMethod == .get
    }

    /// Returns the Jetpack-Tunneled-Request's Parameters
    ///
    var onsaQueryParams: String? {
        guard onsaEncodesParametersInQuery, parameters.isEmpty == false else {
            return nil
        }

        return parameters.toJSONEncoded()
    }

    /// Returns the Jetpack-Tunneled-Request's Body parameters
    ///
    var onsaBodyParams: String? {
        guard onsaEncodesParametersInQuery == false else {
            return nil
        }

        return parameters.toJSONEncoded()
    }
}
