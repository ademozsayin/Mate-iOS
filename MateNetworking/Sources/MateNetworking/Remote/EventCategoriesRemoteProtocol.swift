//
//  EventCategoriesRemoteProtocol.swift
//
//
//  Created by Adem Özsayın on 28.04.2024.
//

import Foundation

public protocol EventCategoriesRemoteProtocol {
    func loadAllProductCategories(
        pageNumber: Int,
        pageSize: Int,
        completion: @escaping (Result<[MateCategory], Error>) -> Void)

}

/// Product Categories: Remote Endpoints
///
public final class EventCategoriesRemote: Remote, EventCategoriesRemoteProtocol {

    // MARK: - Event Categories

    /// Retrieves all of the `MateCategory` available. We rely on the endpoint
    /// defaults for `context`, ` sorting` and `orderby`: `date_gmt` and `asc`
    ///
    /// - Parameters:
    ///     - pageNumber: Number of page that should be retrieved.
    ///     - pageSize: Number of categories to be retrieved per page.
    ///     - completion: Closure to be executed upon completion.
    ///
    public func loadAllProductCategories(
        pageNumber: Int = Default.pageNumber,
        pageSize: Int = Default.pageSize,
        completion: @escaping (Result<[MateCategory], Error>) -> Void
    ) {
        /// Currently no pagination needed
        /// There are three cats at all.
        let parameters = [
            ParameterKey.page: String(pageNumber),
            ParameterKey.perPage: String(pageSize)
        ]

        let path = Path.categories
        let request = OnsaApiRequest(
            method: .get,
            path: path
//            parameters: parameters
        )
        let mapper = EventCategoryListMapper(responseType: .load)

        enqueue(request, mapper: mapper, completion: completion)
    }
  
}

// MARK: - Constants
//
public extension EventCategoriesRemote {
    enum Default {
        public static let pageSize: Int = 25
        public static let pageNumber: Int = 1
    }

    private enum Path {
        static let categories = "categories"
        static let categoriesBatch = "products/categories/batch"
    }

    private enum ParameterKey {
        static let page: String = "page"
        static let perPage: String = "per_page"
        static let name: String = "name"
        static let parent: String = "parent"
        static let create: String = "create"
    }
}
