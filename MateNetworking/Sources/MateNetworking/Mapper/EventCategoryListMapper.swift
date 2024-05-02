//
//  EventCategoryListMapper.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation

/// Mapper: ProductCategory List
///
struct EventCategoryListMapper: Mapper {
   
    /// We're injecting this field via `JSONDecoder.userInfo` because SiteID is not returned in any of the ProductCategory Endpoints.
    ///
    let responseType: ResponseType

    /// (Attempts) to convert a dictionary into [ProductCategory].
    ///
    func map(response: Data) throws -> [MateCategory] {
        let decoder = JSONDecoder()
        

        let hasDataEnvelope = hasDataEnvelope(in: response)

        switch responseType {
        case .load:
            if hasDataEnvelope {
                return try decoder.decode(EventCategoryListEnvelope.self, from: response).productCategories
            } else {
                return try decoder.decode([MateCategory].self, from: response)
            }
        }
    }

    enum ResponseType {
      case load
//      case create
    }
}


/// ProductCategoryListEnvelope Disposable Entity:
/// `Load All Products Categories` endpoint returns the updated products document in the `data` key.
/// This entity allows us to do parse all the things with JSONDecoder.
///
private struct EventCategoryListEnvelope: Decodable {
    let productCategories: [MateCategory]

    private enum CodingKeys: String, CodingKey {
        case productCategories = "data"
    }
}

