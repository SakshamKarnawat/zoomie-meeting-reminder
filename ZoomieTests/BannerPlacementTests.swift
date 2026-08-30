import Foundation
import Testing
@testable import Zoomie

struct BannerPlacementTests {
    @Test func topSitsAtEdgeInset() {
        let offset = BannerPlacement.offsetFromTop(
            visibleHeight: 900,
            bannerHeight: 80,
            fromTop: 0
        )
        #expect(abs(offset - BannerPlacement.edgeInset) < 0.0001)
    }

    @Test func bottomUsesRemainingTravel() {
        let offset = BannerPlacement.offsetFromTop(
            visibleHeight: 900,
            bannerHeight: 80,
            fromTop: 1
        )
        #expect(abs(offset - (900 - 80 - BannerPlacement.edgeInset)) < 0.0001)
    }

    @Test func originYMatchesOffsetFromTop() {
        let frame = CGRect(x: 0, y: 100, width: 1440, height: 900)
        let height = 80.0
        let fromTop = 0.22
        let y = BannerPlacement.originY(visibleFrame: frame, bannerHeight: height, fromTop: fromTop)
        let offset = BannerPlacement.offsetFromTop(
            visibleHeight: frame.height,
            bannerHeight: height,
            fromTop: fromTop
        )
        #expect(abs(y - (frame.maxY - height - offset)) < 0.0001)
    }
}
