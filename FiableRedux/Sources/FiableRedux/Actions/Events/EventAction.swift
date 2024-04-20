//
//  EventAction.swift
//
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation
import MateNetworking

// MARK: - EventAction: Defines all of the Actions supported by the EventAction.
//
public enum EventAction: Action {
    
    case loadEvents(type: EventRemote.EventTypeEndpointType,
                    latitude: Double?,
                    longitude: Double?,
                    categoryId: Int?,
                    page: Int?,
                    completion: (Result<EventPayload, Error>) -> Void)
}
