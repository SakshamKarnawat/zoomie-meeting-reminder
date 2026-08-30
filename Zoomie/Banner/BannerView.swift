import SwiftUI

struct BannerView: View {
    let message: String
    let character: CharacterChoice
    let characterColor: Color
    let customImage: NSImage?
    let theme: BannerTheme
    let font: Font

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            RibbonLabel(message: message, theme: theme, font: font)
            TowingRope(color: theme.rope)
                .zIndex(-1)
            CharacterSprite(choice: character, color: characterColor, customImage: customImage)
        }
        .shadow(color: .black.opacity(0.28), radius: 8, x: 2, y: 5)
        .padding(Design.bannerShadowPadding)
        .fixedSize()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message)
    }
}

#Preview {
    BannerView(
        message: "Call with Jack in 5 minutes",
        character: .cat,
        characterColor: StoredColor.color(fromHex: StoredColor.defaultHex),
        customImage: nil,
        theme: .classic,
        font: BannerFontChoice.rounded.font
    )
    .padding()
    .background(Color(red: 0.78, green: 0.90, blue: 0.98))
}
