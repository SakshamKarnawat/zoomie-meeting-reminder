import SwiftUI

struct BannerBackground: View {
    let theme: BannerTheme

    var body: some View {
        switch theme {
        case .classic:
            Color.white.opacity(0.92)
        case .midnight:
            Color(red: 0.07, green: 0.11, blue: 0.22).opacity(0.94)
        case .sunset:
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.48, blue: 0.22),
                    Color(red: 1.0, green: 0.36, blue: 0.55)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .mint:
            Color(red: 0.72, green: 0.93, blue: 0.80)
        case .bubblegum:
            Color(red: 1.0, green: 0.72, blue: 0.82)
        }
    }
}
