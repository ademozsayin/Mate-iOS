//
//  SystemStatusRemote.swift
//
//
//  Created by Adem Özsayın on 3.05.2024.
//

import Foundation

/// System Status: Remote Endpoint
///
public class SystemStatusRemote: Remote {

    /// Retrieves information from the system status that belongs to the current site.
    /// Currently fetching:
    ///   - Store ID
    ///   - Active Plugins
    ///   - Inactive Plugins
    ///
    /// - Parameters:
    ///   - siteID: Site for which we'll fetch the system plugins.
    ///   - completion: Closure to be executed upon completion.
    ///
    public func loadSystemInformation(completion: @escaping (Result<SystemStatus, Error>) -> Void) {
        let path = Constants.systemStatusPath
        
        let request = OnsaApiRequest(method: .get,
                                     path: path)
        
        let mapper = SystemStatusMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }

}

// MARK: - Constants!
//
private extension SystemStatusRemote {
    enum Constants {
        static let systemStatusPath: String = "system-status"
    }
}
