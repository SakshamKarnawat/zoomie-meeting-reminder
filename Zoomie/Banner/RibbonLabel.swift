import SwiftUI

struct RibbonLabel: View {
    let message: String
    let theme: BannerTheme
    let font: Font

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
            let phase = context.date.timeIntervalSinceReferenceDate * Design.flutterSpeed
            Text(message)
                .font(font)
                .foregroundStyle(theme.foreground)
                .lineLimit(1)
                .padding(.leading, Design.ribbonNotch + Design.bannerHorizontalPadding)
                .padding(.trailing, Design.bannerHorizontalPadding)
                .padding(.vertical, Design.bannerVerticalPadding)
                .background {
                    BannerBackground(theme: theme)
                }
                .clipShape(RibbonShape(phase: phase))
        }
    }
}
