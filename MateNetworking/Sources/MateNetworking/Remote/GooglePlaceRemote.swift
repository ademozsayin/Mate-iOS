//
//  GooglePlaceRemote.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation

public protocol GooglePlaceRemoteProtocol {
    func fetchGooglePlaces() async throws -> MateResponse<[GooglePlace]>
}

///
public class GooglePlaceRemote: Remote, GooglePlaceRemoteProtocol {
    public func fetchGooglePlaces() async throws -> MateResponse<[GooglePlace]> {
        let path = "\(Path.places)"
        let request = OnsaApiRequest( method: .get, path: path)
        return try await enqueue(request)
    }
}

// MARK: - Constants
private extension GooglePlaceRemote {
    enum Path {
        static let places = "google-places/"
    }
}
