import SwiftUI

extension View {
    /// Renders a view if the provided  `condition` is met.
    /// If the `condition` is not met, an `nil`  will be used in place of the receiver view.
    ///
    func renderedIf(_ condition: Bool) -> Self? {
        guard condition else {
            return nil
        }
        return self
    }

    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}


/// Custom view modifer for adding paddings based on given edge insets.
struct InsetPaddings: ViewModifier {
    /// Edges to add paddings to.
    let edges: Edge.Set

    /// Insets for paddings.
    let insets: EdgeInsets

    func body(content: Content) -> some View {
        switch edges {
        case .horizontal:
            content
                .padding(.leading, insets.leading)
                .padding(.trailing, insets.trailing)
        case .vertical:
            content
                .padding(.top, insets.top)
                .padding(.bottom, insets.bottom)
        case .leading:
            content.padding(.leading, insets.leading)
        case .trailing:
            content.padding(.trailing, insets.trailing)
        case .top:
            content.padding(.top, insets.top)
        case .bottom:
            content.padding(.bottom, insets.bottom)
        default:
            content.padding(insets)
        }
    }
}

extension View {
    /// Adds paddings to view with given edge insets
    /// - Parameters:
    ///   - edges: Edges to add paddings to. Default to `.all`
    ///   - insets: Safe area insets to for paddings
    /// - Returns: the modified `View` with paddings.
    func padding(_ edges: Edge.Set = .all, insets: EdgeInsets) -> some View {
        self.modifier(InsetPaddings(edges: edges, insets: insets))
    }
}
