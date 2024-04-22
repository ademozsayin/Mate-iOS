//
//  SwappableSubviewContainerView.swift
//  Mate
//
//  Created by Adem Özsayın on 22.04.2024.
//

import UIKit

/// Container view for a swappable subview.
final class SwappableSubviewContainerView: UIView {
    private var subview: UIView?

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateSubview(_ view: UIView) {
        subview?.removeFromSuperview()

        addSubview(view)
        subview = view
        pinSubviewToAllEdges(view, insets: .zero)
    }
}
