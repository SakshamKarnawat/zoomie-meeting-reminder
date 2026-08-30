import Testing
@testable import Zoomie

struct MenuBarIconTests {
    @Test func usesPawprintSymbolAsTemplateAtMenuBarSize() {
        #expect(MenuBarIcon.symbolName == "pawprint.fill")
        let image = MenuBarIcon.templateImage
        #expect(image.isTemplate)
        #expect(image.size.width == 18)
        #expect(image.size.height == 18)
    }
}
