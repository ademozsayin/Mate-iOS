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
    
    case getNearByEvents(
        latitude: Double,
        longitude: Double,
        categoryId: Int?,
        completion: (Result<[MateEvent], Error>) -> Void)
    
    
    case getUserEvents(page: Int?, completion: (Result<PaginatedResponse<UserEvent>, Error>) -> Void)

    
    case syncUserEvents(page: Int?,completion: (Result<Bool, Error>) -> Void)
}


