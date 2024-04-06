import SwiftUI

struct BadgeView: View {
    enum BadgeType: Equatable {
        case new
        case tip
        case remoteImage(lightUrl: URL, darkUrl: URL?)
        case customText(text: String)

        var title: String? {
            switch self {
            case .new:
                return Localization.newTitle
            case .tip:
                return Localization.tipTitle
            case .customText(let text):
                return text
            case .remoteImage:
                return nil
            }
        }
    }

    /// UI customizations for the badge.
    struct Customizations {
        let textColor: Color
        let backgroundColor: Color

        init(textColor: Color = Color(.textBrand),
             backgroundColor: Color = Color(.wooCommercePurple(.shade0))) {
            self.textColor = textColor
            self.backgroundColor = backgroundColor
        }
    }

    private let type: BadgeType
    private let customizations: Customizations

    init(type: BadgeType) {
        self.type = type
        self.customizations = .init()
    }

    init(text: String, customizations: Customizations = .init()) {
        self.type = .customText(text: text)
        self.customizations = customizations
    }

    var body: some View {
        if let text = type.title {
            Text(text)
                .bold()
                .foregroundColor(customizations.textColor)
                .captionStyle()
                .padding(.leading, Layout.horizontalPadding)
                .padding(.trailing, Layout.horizontalPadding)
                .padding(.top, Layout.verticalPadding)
                .padding(.bottom, Layout.verticalPadding)
                .background(RoundedRectangle(cornerRadius: Layout.cornerRadius)
                    .fill(customizations.backgroundColor)
                )
        } else if case .remoteImage(let lightUrl, let darkUrl) = type {
            AdaptiveAsyncImage(anyAppearanceUrl: lightUrl, darkUrl: darkUrl, scale: 3) { imagePhase in
                switch imagePhase {
                case .success(let image):
                    image.scaledToFit()
                case .empty:
                    BadgeView(type: .new).redacted(reason: .placeholder)
                case .failure:
                    EmptyView()
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            EmptyView()
        }
    }
}

private extension BadgeView.BadgeType {
    enum Localization {
        static let newTitle = NSLocalizedString("New", comment: "Title of the badge shown when advertising a new feature")
        static let tipTitle = NSLocalizedString("Tip", comment: "Title of the badge shown when promoting an existing feature")
    }
}

private extension BadgeView {
    enum Layout {
        static let horizontalPadding: CGFloat = 6
        static let verticalPadding: CGFloat = 4
        static let cornerRadius: CGFloat = 8
    }
}

struct BadgeView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            BadgeView(type: .new)
            BadgeView(type: .tip)
            BadgeView(text: "Custom text")
            BadgeView(text: "Customized colors", customizations: .init(textColor: .green, backgroundColor: .orange))
        }
    }
}
