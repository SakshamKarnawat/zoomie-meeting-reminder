import Testing
@testable import Zoomie

struct BannerMotionTests {
    @Test func endpointsStayPinned() {
        #expect(BannerMotion.progress(elapsedFraction: 0) == 0)
        #expect(BannerMotion.progress(elapsedFraction: 1) == 1)
        #expect(BannerMotion.progress(elapsedFraction: -1) == 0)
        #expect(BannerMotion.progress(elapsedFraction: 2) == 1)
    }

    @Test func easeBoundaryMatchesLinear() {
        let ease = 0.1
        let atEaseIn = BannerMotion.progress(elapsedFraction: ease, easePortion: ease)
        let atEaseOut = BannerMotion.progress(elapsedFraction: 1 - ease, easePortion: ease)
        #expect(abs(atEaseIn - ease) < 0.0001)
        #expect(abs(atEaseOut - (1 - ease)) < 0.0001)
    }

    @Test func middleIsLinear() {
        let mid = BannerMotion.progress(elapsedFraction: 0.5)
        #expect(abs(mid - 0.5) < 0.0001)
        let a = BannerMotion.progress(elapsedFraction: 0.3)
        let b = BannerMotion.progress(elapsedFraction: 0.6)
        #expect(abs((b - a) - 0.3) < 0.0001)
    }

    @Test func durationUsesPixelsPerSecond() {
        let duration = BannerMotion.duration(distance: 2200, pixelsPerSecond: 220)
        #expect(abs(duration - 10) < 0.0001)
    }
}
