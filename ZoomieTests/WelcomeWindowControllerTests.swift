import AppKit
import Testing
@testable import Zoomie

@MainActor
struct WelcomeWindowControllerTests {
    @Test func showReusesTheSameWindow() {
        let catalog = EventCatalog(apple: CalendarService(), google: GoogleCalendarService())
        let controller = WelcomeWindowController(catalog: catalog, onFinished: {})
        controller.showWelcome()
        let first = controller.window
        controller.showWelcome()
        #expect(first != nil)
        #expect(controller.window === first)
        first?.orderOut(nil)
        AppActivation.restoreAccessoryIfNeeded()
    }
}
