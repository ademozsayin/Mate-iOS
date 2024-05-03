//
//  GooglePlaceStore.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import MateNetworking
import MateStorage

import Foundation

final public class GooglePlaceStore: Store {
    private let remote: GooglePlaceRemoteProtocol

    /// Shared private StorageType for use during synchronizeSites and synchronizeSitePlan processes
    ///
    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.writerDerivedStorage
    }()

    public convenience override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        let remote = GooglePlaceRemote(network: network)
        self.init(dispatcher: dispatcher, storageManager: storageManager, network: network, remote: remote)
    }

    init(dispatcher: Dispatcher,
         storageManager: StorageManagerType,
         network: Network,
         remote: GooglePlaceRemoteProtocol) {
        self.remote = remote
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    public override func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: GooglePlacesAction.self)
    }

    /// Receives and executes Actions.
    override public func onAction(_ action: Action) {
        guard let action = action as? GooglePlacesAction else {
            assertionFailure("EventAction received an unsupported action")
            return
        }
        switch action {
       
        case .getGooglePlaces(onCompletion: let onCompletion):
//            getPlaces(completion: onCompletion)
            synchronizeTargetGooglePlaces(onCompletion: onCompletion)
        }
    }
}


// MARK: - Services!
//
private extension GooglePlaceStore {
        
    func getPlaces(
        completion: @escaping (Result<MateResponse<[GooglePlace]>, OnsaApiError>) -> Void) {
        Task { @MainActor in
            do {
                let response = try await remote.fetchGooglePlaces()
                completion(.success(response))
            } catch let error {
                let onsaApiError: OnsaApiError
                switch error {
                case OnsaApiError.invalidToken:
                   onsaApiError = .invalidToken
                case OnsaApiError.requestFailed:
                   onsaApiError = .requestFailed
                default:
                    onsaApiError = .unknown(error: nil, message: error.localizedDescription)
                }
                completion(.failure(onsaApiError))
            }
        }
    }
    
    func synchronizeTargetGooglePlaces( onCompletion: @escaping (Result<MateResponse<[GooglePlace]>, OnsaApiError>) -> Void) {
        Task { @MainActor in
            do {
                let places = try await remote.fetchGooglePlaces()
                DDLogInfo("✅ Google Places fetched")
                upsertGooglePlacesInBackground(readOnlyGooglePlaces: places.data ?? []) { _ in
                    DDLogInfo("✅ Upserting Google Places")
                    onCompletion(.success(places))
                }
            } catch {
                let apiError: OnsaApiError
                if let onsaError = error as? OnsaApiError {
                    apiError = onsaError
                } else {
                    // Handle other types of errors as needed
                    // For example, if error is of type AnyError, you can convert it to OnsaApiError like this:
                    apiError = .unknown(error: error.localizedDescription, message: "X")
                }
                onCompletion(.failure(apiError))
            }
        }
    }

}


// MARK: Storage
private extension GooglePlaceStore {
    /// Updates (OR Inserts) the provided ReadOnly `AddOnGroups` entities *in a background thread*.
    /// onCompletion will be called on the main thread!
    ///
    func upsertGooglePlacesInBackground( readOnlyGooglePlaces: [GooglePlace], onCompletion: @escaping (Result<Void, Error>) -> Void) {
        let derivedStorage = storageManager.writerDerivedStorage
        derivedStorage.perform {
            DDLogInfo("✅ Perform for asycn queue Google Places")
            self.upsertGooglePlaces(readOnlyGooglePlaces: readOnlyGooglePlaces, in: derivedStorage)
        }
        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async {
                onCompletion(.success(()))
            }
        }
    }
    
    /// Updates (OR Inserts) the specified ReadOnly `AddOnGroups` entities into the Storage Layer.
    ///
    func upsertGooglePlaces( readOnlyGooglePlaces: [GooglePlace], in storage: StorageType) {
//        DDLogInfo("✅ Upsert Started")
        readOnlyGooglePlaces.forEach { readOnlyGooglePlace in
            //  Get or create the stored add-on group
            let storedGooglePlace: StorageGooglePlace = {
                guard let existingGroup = storage.loadGooglePlace(placeId: readOnlyGooglePlace.placeID) else {
//                    DDLogInfo("✅ New place added")
                    return storage.insertNewObject(ofType: StorageGooglePlace.self)
                }
                return existingGroup
            }()
//            DDLogInfo("✅ Existing place. Updating")
            // Update values and relationships
            storedGooglePlace.update(with: readOnlyGooglePlace)
//            handleGroupAddOns(readOnlyGroup: readOnlyAddOnGroup, storageGroup: storedAddOnGroup, storage: storage)
        }
        
        // Delete stale groups
//        let activeIDs = readOnlyAddOnGroups.map { $0.groupID }
//        storage.deleteStaleAddOnGroups(siteID: siteID, activeGroupIDs: activeIDs)
    }
}
