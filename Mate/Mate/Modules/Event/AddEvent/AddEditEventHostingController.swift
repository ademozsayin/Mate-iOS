//
//  AddEditEventHostingController.swift
//  Mate
//
//  Created by Adem Özsayın on 27.04.2024.
//

import SwiftUI
import FiableUI
import FiableRedux

final class AddEditEventHostingController: UIHostingController<AddEditEventView> {

    private let viewModel: AddEditEventViewModel

    init(viewModel: AddEditEventViewModel, onDisappear: @escaping () -> Void) {
        self.viewModel = viewModel
        super.init(rootView: AddEditEventView(viewModel))
        rootView.onDisappear = onDisappear
        rootView.dismissHandler = { [weak self] in
            self?.dismiss(animated: true)
        }

    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        presentationController?.delegate = self
    }
}

extension AddEditEventHostingController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        return true//!viewModel.hasChangesMade
    }

    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        UIAlertController.presentDiscardChangesActionSheet(viewController: self) { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}
