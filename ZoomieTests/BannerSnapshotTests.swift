import SwiftUI
import Testing
@testable import Zoomie

@MainActor
struct BannerSnapshotTests {
    @Test func ribbonUnitRendersAtReadableSize() {
        let view = BannerView(
            message: "Call with Jack in 5 minutes",
            character: .duck,
            customImage: nil,
            theme: .classic,
            font: BannerFontChoice.rounded.font
        )
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2
        guard let nsImage = renderer.nsImage else {
            Issue.record("ImageRenderer produced no image")
            return
        }
        #expect(nsImage.size.width > 200)
        #expect(nsImage.size.height > 40)
    }
}
