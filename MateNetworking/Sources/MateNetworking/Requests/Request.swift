//
//  Request.swift
//  Networking
//
//  Created by Adem Özsayın on 18.03.2024.
//

import Alamofire
import Foundation
protocol Request: URLRequestConvertible {
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: A URL request.
    func asURLRequest() throws -> URLRequest

    /// Returns a closure that tries to parse a response looking for an error
    ///
    func responseDataValidator() -> ResponseDataValidator
}
