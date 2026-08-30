import SwiftUI

struct RibbonLabel: View {
    let message: String
    let theme: BannerTheme
    let font: Font

    var body: some View {
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
            .clipShape(RibbonShape())
    }
}
