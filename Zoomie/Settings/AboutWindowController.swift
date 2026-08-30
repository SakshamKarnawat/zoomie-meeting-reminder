import AppKit
import SwiftUI

@MainActor
final class AboutWindowController: NSWindowController, NSWindowDelegate {
    private let updates: AppUpdateService

    init(updates: AppUpdateService) {
        self.updates = updates
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused")
    }

    func showAbout() {
        if window == nil {
            window = makeWindow()
        }
        AppActivation.bringToFront(window!)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        AppActivation.restoreAccessoryIfNeeded()
        return false
    }

    private func makeWindow() -> NSWindow {
        let hosting = NSHostingController(rootView: AboutView(updates: updates))
        let window = NSWindow(contentViewController: hosting)
        window.title = "About Zoomie"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("ZoomieAbout")
        window.center()
        return window
    }
}
