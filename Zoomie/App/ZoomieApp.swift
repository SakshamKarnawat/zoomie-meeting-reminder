import SwiftUI

@main
struct ZoomieApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenu(
                settings: appDelegate.runtime.settings,
                calendarService: appDelegate.runtime.calendarService,
                nextEvent: appDelegate.runtime.nextUpcomingEvent,
                joinEvent: appDelegate.runtime.joinMeeting,
                openSettings: appDelegate.runtime.openSettings,
                previewBanner: appDelegate.runtime.previewBanner,
                syncCalendars: appDelegate.runtime.syncCalendars,
                openAbout: appDelegate.runtime.openAbout,
                updateApp: appDelegate.runtime.updateApp,
                quit: quitApp
            )
        } label: {
            Image(nsImage: MenuBarIcon.templateImage)
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
