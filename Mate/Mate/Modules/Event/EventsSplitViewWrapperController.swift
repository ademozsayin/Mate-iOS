//
//  EventsSplitViewWrapperController.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import UIKit
import FiableRedux

/// Controller to wrap the products split view
///
final class EventsSplitViewWrapperController: UIViewController {
    private lazy var coordinator: EventsSplitViewCoordinator = EventsSplitViewCoordinator(splitViewController: productsSplitViewController)
    private lazy var productsSplitViewController = OnsaSplitViewController(columnForCollapsingHandler: handleCollapsingSplitView,
                                                                          didExpandHandler: handleDidExpand)

    init() {
        super.init(nibName: nil, bundle: nil)
        configureTabBarItem()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startProductCreation() {
        coordinator.startProductCreation()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureChildViewController()
        coordinator.start()
    }

    override var shouldShowOfflineBanner: Bool {
        return true
    }
}

private extension EventsSplitViewWrapperController {
    func handleCollapsingSplitView(splitViewController: UISplitViewController) -> UISplitViewController.Column {
        coordinator.columnToShowWhenSplitViewIsCollapsing()
    }

    func handleDidExpand(splitViewController: UISplitViewController) {
        coordinator.didExpand()
    }
}

private extension EventsSplitViewWrapperController {
    func configureTabBarItem() {
        tabBarItem.title = Localization.tabTitle
        tabBarItem.image = .productImage
        tabBarItem.accessibilityIdentifier = "tab-bar-products-item"
    }

    func configureChildViewController() {
        guard let contentView = productsSplitViewController.view else {
            return assertionFailure("Split view not available")
        }
        addChild(productsSplitViewController)
        view.addSubview(contentView)
        productsSplitViewController.didMove(toParent: self)

        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.pinSubviewToAllEdges(contentView)
    }
}

extension EventsSplitViewWrapperController {
    private enum Localization {
        static let tabTitle = NSLocalizedString("eventsTab.tabTitle",
                                                value: "Events",
                                                comment: "Title of the Products tab — plural form of Product")
    }
}
