import SwiftUI

@main
struct ZoomieApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra("Zoomie", systemImage: "bird") {
            MenuBarMenu(
                settings: appDelegate.runtime.settings,
                previewBanner: appDelegate.runtime.previewBanner,
                quit: quitApp
            )
        }

        Settings {
            SettingsView(
                settings: appDelegate.runtime.settings,
                calendarService: appDelegate.runtime.calendarService,
                previewBanner: appDelegate.runtime.previewBanner
            )
        }
    }

    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}
