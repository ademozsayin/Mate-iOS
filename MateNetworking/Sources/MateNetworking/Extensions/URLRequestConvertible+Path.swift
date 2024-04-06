//
//  URLRequestConvertible+Path.swift
//  Networking
//
//  Created by Adem Özsayın on 25.03.2024.
//

import Foundation
import Alamofire

extension URLRequestConvertible {
    /// Path of a network request in `Remote` for analyzing the decoding errors.
    var pathForAnalytics: String? {
        if let dotcomRequest = self as? DotcomRequest {
            return dotcomRequest.path
        } else {
            return nil
        }
    }
}
