//
//  Sample.swift
//  Components
//
//  Created by Adem Özsayın on 28.02.2024.
//

import UIKit


// MARK: - WeatherHeaderView
final public class WeatherHeaderView: UIView, NibOwnerLoadable {
    // MARK: - Init
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
        backgroundColor = .systemPink
    }
}
