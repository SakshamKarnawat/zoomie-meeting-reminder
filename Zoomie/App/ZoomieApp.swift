import SwiftUI

@main
struct ZoomieApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarMenu(
                settings: appDelegate.runtime.settings,
                openSettings: appDelegate.runtime.openSettings,
                previewBanner: appDelegate.runtime.previewBanner,
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
