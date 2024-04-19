//
//  EventRemote.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//

import Foundation

//nearby?latitude=41.0449&longitude=28.9800
//?category_id=1
//?page=1
public protocol EventRemoteProtocol {
    func loadEvents(_for type: EventRemote.EventTypeEndpointType,
                    latitude: Double?,
                    longitude: Double?,
                    page: Int?,
                    completion: @escaping (Result<EventPayload, Error>) -> Void)
    
}

/// Notifications: Remote Endpoints
///
public final class EventRemote: Remote, EventRemoteProtocol {
    public func loadEvents(
        _for type: EventTypeEndpointType,
        latitude: Double?,
        longitude: Double?,
        page: Int?,
        completion: @escaping (Result<EventPayload, any Error>
    ) -> Void) {
        
        let request = requestForEvents(type: type, latitude: latitude, longitude: longitude, page: page)
        let mapper = EventPayloadMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }
}


// MARK: - Private Methods
//
private extension EventRemote {

    func requestForEvents(type: EventTypeEndpointType, latitude: Double?, longitude: Double?, page: Int?) -> OnsaApiRequest {
        var path = ""
        var parameters: [String:Any] = [:]
        
        switch type {
        case .nearBy:
            path = Paths.nearby
            
            if let latitude {
                parameters[ParameterKeys.latitude] = String(latitude)
            }
            
            if let longitude {
                parameters[ParameterKeys.longitude] = String(longitude)
            }
            
        case .all:
            path = Paths.events
        }
        
        if let page {
            parameters[ParameterKeys.page] = String(page)
        }
        
        return OnsaApiRequest(method: .get, path: path, parameters: parameters)
    }
}

public extension EventRemote {
    enum EventTypeEndpointType {
        case nearBy
        case all
    }
}

// MARK: - Constants!

private extension EventRemote {

    enum Paths {
        static let events = "events/"
        static let nearby = "events/nearby/"
    }

    enum ParameterKeys {
        static let longitude = "longitude"
        static let latitude = "latitude"
        static let page = "page"
    }
}
