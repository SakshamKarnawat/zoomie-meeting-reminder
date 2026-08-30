import SwiftUI
import Testing
@testable import Zoomie

struct CharacterPaintTests {
    @Test func lightFillGetsDarkerPlate() {
        #expect(StoredColor.luminance(of: CharacterPaint.plate(for: .white)) < 0.45)
    }

    @Test func darkFillGetsLighterPlate() {
        #expect(StoredColor.luminance(of: CharacterPaint.plate(for: .black)) > 0.5)
    }
}
