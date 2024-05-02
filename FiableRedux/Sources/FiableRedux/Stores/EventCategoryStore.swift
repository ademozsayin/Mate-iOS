//
//  ProductCategoryStore.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation
import MateNetworking
import MateStorage

// MARK: - EventCategoryStore
//
public final class EventCategoryStore: Store {
    private let remote: EventCategoriesRemoteProtocol

    private lazy var sharedDerivedStorage: StorageType = {
        return storageManager.writerDerivedStorage
    }()

    public override init(dispatcher: Dispatcher, storageManager: StorageManagerType, network: Network) {
        self.remote = EventCategoriesRemote(network: network)
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    init(dispatcher: Dispatcher,
         storageManager: StorageManagerType,
         network: Network,
         remote: EventCategoriesRemoteProtocol) {
        self.remote = remote
        super.init(dispatcher: dispatcher, storageManager: storageManager, network: network)
    }

    /// Registers for supported Actions.
    ///
    override public func registerSupportedActions(in dispatcher: Dispatcher) {
        dispatcher.register(processor: self, for: EventCategoryAction.self)
    }

    /// Receives and executes Actions.
    ///
    override public func onAction(_ action: Action) {
        guard let action = action as? EventCategoryAction else {
            assertionFailure("EventCategoryAction received an unsupported action")
            return
        }

        switch action {
        case let .synchronizeProductCategories(fromPageNumber, onCompletion):
            synchronizeProductCategories( pageNumber: fromPageNumber, pageSize: 1, onCompletion: onCompletion)
       
        case .synchronizeProductCategory( categoryID: let CategoryID, onCompletion: let onCompletion):
            synchronizeProductCategory( categoryID: CategoryID, onCompletion: onCompletion)
       
        }
    }
}

// MARK: - Services
//
private extension EventCategoryStore {

    /// Synchronizes product categories associated with a given Site ID.
    ///
    func synchronizeProductCategories( pageNumber: Int, pageSize: Int, onCompletion: @escaping (Result<[MateCategory], Error>) -> Void) {
        remote.loadAllProductCategories(pageNumber: pageNumber, pageSize: pageSize) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let productCategories):
                self.upsertStoredProductCategoriesInBackground(productCategories) {
                    onCompletion(.success(productCategories))
                }
            case .failure(let error):
                onCompletion(.failure(error))
            }
        }
    }

    /// Loads a remote product category associated with the given Category ID and Site ID
    ///
    func synchronizeProductCategory(categoryID: Int64, onCompletion: @escaping (Result<MateCategory, Error>) -> Void) {

    }

}

// MARK: - Storage: ProductCategory
//
private extension EventCategoryStore {
    /// Updates (OR Inserts) the specified ReadOnly ProductCategory Entities *in a background thread*.
    /// onCompletion will be called on the main thread!
    ///
    func upsertStoredProductCategoriesInBackground(
        _ readOnlyProductCategories: [MateNetworking.MateCategory],
        onCompletion: @escaping () -> Void
    ) {
        let derivedStorage = sharedDerivedStorage
        derivedStorage.perform { [weak self] in
            self?.upsertStoredProductCategories(readOnlyProductCategories, in: derivedStorage)
        }

        storageManager.saveDerivedType(derivedStorage: derivedStorage) {
            DispatchQueue.main.async(execute: onCompletion)
        }
    }
}

private extension EventCategoryStore {
    /// Updates (OR Inserts) the specified ReadOnly ProductCategory entities into the Storage Layer.
    ///
    /// - Parameters:
    ///     - readOnlyProducCategories: Remote ProductCategories to be persisted.
    ///     - storage: Where we should save all the things!
    ///     - siteID: site ID for looking up the ProductCategory.
    ///
    func upsertStoredProductCategories(
        _ readOnlyProductCategories: [MateNetworking.MateCategory],
        in storage: StorageType
    ) {
        // Upserts the ProductCategory models from the read-only version
        for readOnlyProductCategory in readOnlyProductCategories {
            let storageProductCategory: MateStorage.EventCategory = {
                if let storedCategory = storage.loadProductCategory(categoryID: Int64(readOnlyProductCategory.id)) {
                    return storedCategory
                }
                return storage.insertNewObject(ofType: MateStorage.EventCategory.self)
            }()
            storageProductCategory.update(with: readOnlyProductCategory)
        }
    }
}

// MARK: - Constant
//
private extension EventCategoryStore {
    enum Constants {
        /// Max number allwed by the API to maximize our changces on getting all item in one request.
        ///
        static let defaultMaxPageSize = 100
    }
}
