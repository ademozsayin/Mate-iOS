//
//  FilterProductCategoryListViewController.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import Foundation
import UIKit
import FiableRedux
import MateNetworking

/// Displays the list of ProductCategories associated to the active Account,
/// and allows the selection of one of them, or any.
///
final class FilterProductCategoryListViewController: UIViewController {

    private let productCategoryListViewController: ProductCategoryListViewController
    private let viewModel: FilterProductCategoryListViewModel

    init(
        selectedCategory: MateCategory?,
        onProductCategorySelection: ProductCategoryListViewModel.ProductCategorySelection? = nil
    ) {
        self.viewModel = FilterProductCategoryListViewModel(anyCategoryIsSelected: selectedCategory == nil)

        var selectedCategories: [MateCategory] = []
        if let selectedCategory = selectedCategory {
            selectedCategories.append(selectedCategory)
        }

        let productCategoryListViewModel = ProductCategoryListViewModel(
                                                                        selectedCategories: selectedCategories,
                                                                        enrichingDataSource: viewModel,
                                                                        delegate: viewModel,
                                                                        onProductCategorySelection: onProductCategorySelection)

        productCategoryListViewController = ProductCategoryListViewController(viewModel: productCategoryListViewModel)

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureProductCategoryListView()
        configureTitle()
    }
}

private extension FilterProductCategoryListViewController {
    func configureProductCategoryListView() {
        addChild(productCategoryListViewController)
        attachSubview(productCategoryListViewController.view)
        productCategoryListViewController.didMove(toParent: self)
    }

    func attachSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(subview)
        view.pinSubviewToAllEdges(subview)
    }

    func configureTitle() {
        title = viewModel.title
    }
}
