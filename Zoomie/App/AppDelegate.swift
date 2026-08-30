import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let runtime = AppRuntime()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        Task { await runtime.start() }
        if ProcessInfo.processInfo.arguments.contains("--preview-banner") {
            Task {
                try? await Task.sleep(for: .milliseconds(700))
                runtime.previewBanner()
            }
        }
    }
}
