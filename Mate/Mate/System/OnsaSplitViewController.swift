//
//  OnsaSplitViewController.swift
//  Mate
//
//  Created by Adem Özsayın on 10.04.2024.
//

import UIKit

/// Custom split view controller with double column style with preferred tile split behavior and 2-column display mode.
/// When collapsed, the split view falls back to display the primary column.
///
final class OnsaSplitViewController: UISplitViewController {

    /// Convenient type for the closure to handle collapsing a split view
    ///
    typealias ColumnForCollapsingHandler = (UISplitViewController) -> UISplitViewController.Column

    private let columnForCollapsingHandler: ColumnForCollapsingHandler?

    private let didExpandHandler: ((UISplitViewController) -> Void)?

    /// Init a split view with an optional handler to decide which column to collapse the split view into.
    /// By default, always display the primary column when collapsed.
    init(columnForCollapsingHandler: ColumnForCollapsingHandler? = nil,
         didExpandHandler: ((UISplitViewController) -> Void)? = nil) {
        self.columnForCollapsingHandler = columnForCollapsingHandler
        self.didExpandHandler = didExpandHandler
        super.init(style: .doubleColumn)
        configureCommonStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureCommonStyle() {
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .tile
        delegate = self
    }
}

extension OnsaSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController,
                             topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return columnForCollapsingHandler?(splitViewController) ?? proposedTopColumn
    }

    func splitViewController(_ splitViewController: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        // Automatically hides the default toggle button if displaying 2 columns.
        splitViewController.presentsWithGesture = displayMode != .oneBesideSecondary
    }

    func splitViewControllerDidExpand(_ svc: UISplitViewController) {
        didExpandHandler?(svc)
    }
}
