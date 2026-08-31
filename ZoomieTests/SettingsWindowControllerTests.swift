import AppKit
import Testing
@testable import Zoomie

@MainActor
struct SettingsWindowControllerTests {
    @Test func showReusesTheSameWindow() {
        let controller = SettingsWindowController(
            settings: SettingsStore(),
            catalog: EventCatalog(apple: CalendarService(), google: GoogleCalendarService()),
            previewBanner: {},
            syncCalendars: {},
            updates: AppUpdateService()
        )
        controller.showSettings()
        let first = controller.window
        controller.showSettings()
        #expect(first != nil)
        #expect(controller.window === first)
        first?.orderOut(nil)
    }
}
