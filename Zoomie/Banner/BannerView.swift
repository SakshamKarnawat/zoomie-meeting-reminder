import SwiftUI

struct BannerView: View {
    let message: String
    let character: CharacterChoice
    let customImage: NSImage?
    let theme: BannerTheme
    let font: Font

    var body: some View {
        HStack(spacing: 12) {
            CharacterView(choice: character, customImage: customImage)
            Text(message)
                .font(font)
                .foregroundStyle(theme.foreground)
                .lineLimit(1)
        }
        .padding(.horizontal, Design.bannerHorizontalPadding)
        .padding(.vertical, Design.bannerVerticalPadding)
        .background {
            BannerBackground(theme: theme)
        }
        .clipShape(.rect(cornerRadius: Design.bannerCornerRadius))
        .fixedSize()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

#Preview {
    BannerView(
        message: "Standup in 5 min",
        character: .duck,
        customImage: nil,
        theme: .sunset,
        font: BannerFontChoice.rounded.font
    )
    .padding()
}
