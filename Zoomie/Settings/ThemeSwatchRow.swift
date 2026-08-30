import SwiftUI

struct ThemeSwatchRow: View {
    let theme: BannerTheme

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 6)
                .fill(.clear)
                .frame(width: 44, height: 28)
                .overlay {
                    BannerBackground(theme: theme)
                        .clipShape(.rect(cornerRadius: 6))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(.secondary.opacity(0.4), lineWidth: 1)
                }
            Text(theme.title)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Preview, \(theme.title)")
    }
}
