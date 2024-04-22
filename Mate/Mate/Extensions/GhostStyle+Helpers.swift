//
//  GhostStyle+Helpers.swift
//  Mate
//
//  Created by Adem Özsayın on 23.04.2024.
//

import FiableFoundation
import FiableUI

///
extension GhostStyle {
    static var wooDefaultGhostStyle: Self {
        return GhostStyle(beatDuration: Defaults.beatDuration,
                          beatStartColor: .listForeground(modal: false),
                          beatEndColor: .ghostCellAnimationEndColor)
    }
}
