import Foundation
import Testing
@testable import Zoomie

struct InstalledBrowsersTests {
    @Test func knowsCommonBrowsers() {
        #expect(InstalledBrowsers.isKnown("com.apple.Safari"))
        #expect(InstalledBrowsers.isKnown("com.google.Chrome"))
        #expect(InstalledBrowsers.isKnown("org.mozilla.firefox"))
        #expect(!InstalledBrowsers.isKnown("app.zoomie.Zoomie"))
        #expect(!InstalledBrowsers.isKnown("com.apple.mail"))
    }
}
