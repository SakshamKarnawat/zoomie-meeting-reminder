import SwiftUI

struct BannerPositionPreview: View {
    let fromTop: Double
    let screenSize: CGSize

    var body: some View {
        GeometryReader { geo in
            let fitted = fittedScreen(in: geo.size)
            let markWidth = max(28, min(screenSize.width * fitted.scale * 0.42, 90))
            let markHeight = max(6, Design.bannerMinHeight * fitted.scale)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.primary.opacity(0.06))
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(.secondary.opacity(0.45), lineWidth: 1)

                BannerPositionMark(width: markWidth, height: markHeight)
                    .offset(
                        x: (fitted.size.width - markWidth) / 2,
                        y: BannerPlacement.offsetFromTop(
                            visibleHeight: screenSize.height,
                            bannerHeight: Design.bannerMinHeight,
                            fromTop: fromTop
                        ) * fitted.scale
                    )
            }
            .frame(width: fitted.size.width, height: fitted.size.height)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(screenSize.width / max(screenSize.height, 1), contentMode: .fit)
        .frame(height: 120)
        .accessibilityLabel("Banner position preview")
    }

    private func fittedScreen(in size: CGSize) -> (size: CGSize, scale: Double) {
        let scale = min(size.width / max(screenSize.width, 1), size.height / max(screenSize.height, 1))
        return (CGSize(width: screenSize.width * scale, height: screenSize.height * scale), scale)
    }
}
