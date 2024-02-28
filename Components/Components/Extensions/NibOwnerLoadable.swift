//
//  NibOwnerLoadable.swift
//  Components
//
//  Created by Adem Özsayın on 28.02.2024.
//
import UIKit
public protocol NibOwnerLoadable: AnyObject {
    /// The nib file to use to load a new instance of the View designed in a XIB
    static var nib: UINib { get }
    
    /// The bundle containing the resources
    static var bundle: Bundle { get }
}

public extension NibOwnerLoadable {
    /// By default, use the nib which has the same name as the name of the class,
    /// and located in the bundle of that class
    static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: bundle)
    }
    
    /// By default, use the framework bundle
    static var bundle: Bundle {
        return Bundle(for: Self.self)
    }
}

public extension NibOwnerLoadable where Self: UIView {
    /**
     Adds content loaded from the nib to the end of the receiver's list of subviews and adds constraints automatically.
     */
    func loadNibContent() {
        let layoutAttributes: [NSLayoutConstraint.Attribute] = [.top, .leading, .bottom, .trailing]
        for case let view as UIView in type(of: self).nib.instantiate(withOwner: self, options: nil) {
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            view.layer.masksToBounds = false
            self.addSubview(view)
            NSLayoutConstraint.activate(layoutAttributes.map { attribute in
                NSLayoutConstraint(
                    item: view,
                    attribute: attribute,
                    relatedBy: .equal,
                    toItem: self,
                    attribute: attribute,
                    multiplier: 1,
                    constant: 0.0
                )
            })
        }
    }
}
