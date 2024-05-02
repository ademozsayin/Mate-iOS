//
//  GooglePlacesAction.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import MateNetworking

public enum GooglePlacesAction: Action {

    /// Retrieves google places for creating event.
    case getGooglePlaces(onCompletion: (Result<MateResponse<[GooglePlace]>, OnsaApiError>) -> Void)
}
