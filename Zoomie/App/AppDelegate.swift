import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let runtime = AppRuntime()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        Task { await runtime.start() }
    }
}
