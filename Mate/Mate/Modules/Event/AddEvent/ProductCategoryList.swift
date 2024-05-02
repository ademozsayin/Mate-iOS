//
//  ProductCategoryList.swift
//  Mate
//
//  Created by Adem Özsayın on 28.04.2024.
//

import SwiftUI

/// SwiftUI wrapper of `ProductCategoryListViewController`.
///
struct ProductCategoryList: UIViewControllerRepresentable {
    private let viewModel: ProductCategoryListViewModel
    private let config: EventCategoryConfiguration

    init(viewModel: ProductCategoryListViewModel, config: EventCategoryConfiguration) {
        self.viewModel = viewModel
        self.config = config
    }

    func makeUIViewController(context: Context) -> ProductCategoryListViewController {
        return ProductCategoryListViewController(viewModel: viewModel, configuration: config)
    }

    func updateUIViewController(_ uiViewController: ProductCategoryListViewController, context: Context) {
        // no=op
    }
}
