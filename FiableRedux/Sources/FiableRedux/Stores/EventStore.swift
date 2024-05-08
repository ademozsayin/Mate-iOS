//
//  EventStore.swift
//  
//
//  Created by Adem Özsayın on 19.04.2024.
//
import MateNetworking
import MateStorage
import UIKit

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
        case .getNearByEvents(latitude: let latitude, longitude: let longitude, categoryId: let categoryId, completion: let completion):
            loadNearbyEvents(latitude: latitude, longitude: longitude, categoryId: categoryId, completion: completion)
        case .getUserEvents(page: let page, completion: let completion):
            getUserEvents(page: page, completion: completion)
        case .syncUserEvents(page: let page, completion: let completion ):
            syncUserEvents(page: page, completion: completion)
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
    
    func loadNearbyEvents(
        latitude: Double,
        longitude: Double,
        categoryId: Int?,
        completion: @escaping (Result<[MateEvent], Error>) -> Void
    ) {
        remote.getNearbyEvents(latitude: latitude, longitude: longitude, categoryId: categoryId, completion: completion)
    }
    
    func getUserEvents(page:Int? ,completion: @escaping (Result<PaginatedResponse<UserEvent>, Error>) -> Void) {
        remote.getUserEvents(page: page, completion: completion)
    }
    
    func syncUserEvents(page: Int?, completion: @escaping (Result<Bool, Error>) -> Void) {
        
        remote.getUserEvents(page: page) { result in
            switch result {
            case .success(let data):
                let shouldDeleteExistingProducts = page == Default.firstPageNumber
                self.upsertStoredProductsInBackground(
                    readOnlyProducts: data.data ?? [],
                    shouldDeleteExistingProducts: shouldDeleteExistingProducts
                ) {
                    let hasNextPage = data.next_page_url != nil
                    completion(.success(hasNextPage))
                    }
            case .failure(let error):
                print(error)
            }
        }
    }
}

// MARK: - Storage: Product
//
extension EventStore {
    
    /// Deletes any MateStorage.UserEvent with the specified `productID` = which is id
    ///
    func deleteStoredProduct( productID: Int64) {
        let storage = storageManager.viewStorage
        guard let product = storage.loadProduct(productID: productID) else {
            return
        }
        
        storage.deleteObject(product)
        storage.saveIfNeeded()
    }
    
    /// Updates (OR Inserts) the specified ReadOnly Product Entities *in a background thread*.
    /// Also deletes existing products if requested.
    /// `onCompletion` will be called on the main thread!
    ///
    func upsertStoredProductsInBackground(readOnlyProducts: [MateNetworking.UserEvent],
                                          shouldDeleteExistingProducts: Bool = false,
                                          onCompletion: @escaping () -> Void) {
        let derivedStorage = sharedDerivedStorage
        derivedStorage.perform {
            if shouldDeleteExistingProducts {
                derivedStorage.deleteProducts()
            }
            self.upsertStoredProducts(readOnlyProducts: readOnlyProducts, in: derivedStorage)
        }
        
        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async(execute: onCompletion)
        }
    }
    
    /// Updates (OR Inserts) the specified ReadOnly Product Entities into the Storage Layer.
    ///
    /// - Parameters:
    ///     - readOnlyProducts: Remote Products to be persisted.
    ///     - storage: Where we should save all the things!
    ///
    func upsertStoredProducts(readOnlyProducts: [MateNetworking.UserEvent], in storage: StorageType) {
        for readOnlyProduct in readOnlyProducts {
            // The "importing" status is only used for product import placeholders and should not be stored.
            guard readOnlyProduct.productStatus != .importing else {
                continue
            }
            let storageProduct = storage.loadProduct(productID: Int64(readOnlyProduct.id)) ??
            storage.insertNewObject(ofType: MateStorage.UserEvent.self)
            storageProduct.update(with: readOnlyProduct)
       
        }
    }
}
