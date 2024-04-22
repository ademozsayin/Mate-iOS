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
                    categoryId: Int?,
                    page: Int?,
                    completion: @escaping (Result<EventPayload, Error>) -> Void)
    
    func getNearbyEvents(
        latitude: Double,
        longitude: Double,
        categoryId: Int?,
        completion: @escaping (Result<[MateEvent], Error>) -> Void)
    
}

/// Events: Remote Endpoints
///
public final class EventRemote: Remote, EventRemoteProtocol {
   
    public func loadEvents(
        _for type: EventTypeEndpointType,
        latitude: Double?,
        longitude: Double?,
        categoryId: Int?,
        page: Int?,
        completion: @escaping (Result<EventPayload, any Error>
    ) -> Void) {
        
        let request = requestForEvents(
            type: type,
            latitude: latitude,
            longitude: longitude,
            categoryId: categoryId,
            page: page
        )
        
        
        let mapper = EventPayloadMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }
    
    public func getNearbyEvents(latitude: Double, longitude: Double, categoryId: Int?, completion: @escaping (Result<[MateEvent], any Error>) -> Void) {
        
        let request = requestForEvents(
            type: .nearBy,
            latitude: latitude,
            longitude: longitude,
            categoryId: categoryId,
            page: nil
        )
        
        let mapper = NearbyEventMapper()

        enqueue(request, mapper: mapper, completion: completion)
    }
    
}


// MARK: - Private Methods
//
private extension EventRemote {

    func requestForEvents(
        type: EventTypeEndpointType,
        latitude: Double?,
        longitude: Double?,
        categoryId:Int?,
        page: Int?
    ) -> OnsaApiRequest {
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
        
        if let categoryId {
            parameters[ParameterKeys.categoryId] = String(categoryId)
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
        static let categoryId = "category_id"
    }
}
