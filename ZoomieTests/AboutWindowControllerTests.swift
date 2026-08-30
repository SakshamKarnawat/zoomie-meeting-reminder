import AppKit
import Testing
@testable import Zoomie

@MainActor
struct AboutWindowControllerTests {
    @Test func showReusesTheSameWindow() {
        let controller = AboutWindowController(updates: AppUpdateService())
        controller.showAbout()
        let first = controller.window
        controller.showAbout()
        #expect(first != nil)
        #expect(controller.window === first)
        first?.orderOut(nil)
        AppActivation.restoreAccessoryIfNeeded()
    }
}
