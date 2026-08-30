import AppKit
import Testing
@testable import Zoomie

@MainActor
struct SettingsWindowControllerTests {
    @Test func showReusesTheSameWindow() {
        let controller = SettingsWindowController(
            settings: SettingsStore(),
            calendarService: CalendarService(),
            previewBanner: {}
        )
        controller.showSettings()
        let first = controller.window
        controller.showSettings()
        #expect(first != nil)
        #expect(controller.window === first)
        first?.orderOut(nil)
    }
}
