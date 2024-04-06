import Foundation
import UIKit

/// UIImageView with a circular shape.
///
public class CircularImageView: UIImageView {

    public override var frame: CGRect {
        didSet {
            refreshRadius()
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        refreshRadius()
    }

    private func refreshRadius() {
        layer.cornerRadius = frame.width * 0.5
        layer.masksToBounds = true
    }
}
