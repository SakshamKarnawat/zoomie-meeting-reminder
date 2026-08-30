import Foundation

enum BannerPlacement {
    static let edgeInset: Double = 8

    /// Distance from the top of the visible screen to the top of the banner.
    static func offsetFromTop(
        visibleHeight: Double,
        bannerHeight: Double,
        fromTop: Double,
        edgeInset: Double = edgeInset
    ) -> Double {
        let t = min(max(fromTop, 0), 1)
        let travel = max(visibleHeight - bannerHeight - 2 * edgeInset, 0)
        return edgeInset + travel * t
    }

    /// AppKit origin.y (bottom-left) for the banner window.
    static func originY(
        visibleFrame: CGRect,
        bannerHeight: Double,
        fromTop: Double
    ) -> Double {
        let offset = offsetFromTop(
            visibleHeight: visibleFrame.height,
            bannerHeight: bannerHeight,
            fromTop: fromTop
        )
        return visibleFrame.maxY - bannerHeight - offset
    }

    static func startX(visibleFrame: CGRect, bannerWidth: Double) -> Double {
        visibleFrame.minX - bannerWidth
    }

    static func endX(visibleFrame: CGRect) -> Double {
        visibleFrame.maxX
    }
}
