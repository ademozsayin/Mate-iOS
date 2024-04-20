//
//  EventStore.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//
import MateNetworking
import MateStorage

// TODO: - Save events to Storage for offline usage

final public class EventStore: Store {
    private let remote: EventRemoteProtocol

    /// Shared private StorageType for use during synchronizeSites and synchronizeSitePlan processes
    ///
    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.writerDerivedStorage
    }()

    public convenience override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        let remote = EventRemote(network: network)
        self.init(dispatcher: dispatcher, storageManager: storageManager, network: network, remote: remote)
    }

    init(dispatcher: Dispatcher,
         storageManager: StorageManagerType,
         network: Network,
         remote: EventRemoteProtocol) {
        self.remote = remote
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    public override func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: EventAction.self)
    }

    /// Receives and executes Actions.
    override public func onAction(_ action: Action) {
        guard let action = action as? EventAction else {
            assertionFailure("EventAction received an unsupported action")
            return
        }
        switch action {
        case .loadEvents(let type,
                         let latitude,
                         let longitude,
                         let categoryId,
                         let page,
                         let completion):
            loadEvents(
                _for: type,
               latitude: latitude,
               longitude: longitude,
               categoryId: categoryId,
               page: page,
               completion: completion
            )
        }
    }
}


// MARK: - Services!
//
private extension EventStore {
    ///
    func loadEvents(_for type: EventRemote.EventTypeEndpointType,
                    latitude: Double?,
                    longitude: Double?,
                    categoryId: Int?,
                    page: Int?,
                    completion: @escaping (Result<EventPayload, Error>) -> Void) {
        remote.loadEvents(
            _for: type,
            latitude: latitude,
            longitude: longitude,
            categoryId: categoryId,
            page: page,
            completion: completion
        )
        
    }

}
