//
//  RequestConverter.swift
//  Networking
//
//  Created by Adem Özsayın on 17.03.2024.
//

import Alamofire

/// Converter to convert Jetpack tunnel requests into REST API requests if needed
///
public struct RequestConverter {
    let credentials: Credentials?

    func convert(_ request: URLRequestConvertible) -> URLRequestConvertible {
        if request is RESTRequest {
            return request
        }
        let siteAddress: String? = {
            switch credentials {
            case let .wporg(_, _, siteAddress):
                return siteAddress
            default:
                return nil
            }
        }()
        guard let convertibleRequest = request as? RESTRequestConvertible,
              let siteAddress,
              let restRequest = convertibleRequest.asRESTRequest(with: siteAddress) else {
            return request
        }

        return restRequest
    }
}
