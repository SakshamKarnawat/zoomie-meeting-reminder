import AppKit
import SwiftUI

@MainActor
final class WelcomeWindowController: NSWindowController, NSWindowDelegate {
    private let catalog: EventCatalog
    private let onFinished: () -> Void

    init(catalog: EventCatalog, onFinished: @escaping () -> Void) {
        self.catalog = catalog
        self.onFinished = onFinished
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused")
    }

    func showWelcome() {
        if window == nil {
            window = makeWindow()
        }
        AppActivation.bringToFront(window!)
    }

    func dismiss() {
        catalog.google.cancelSignIn()
        window?.orderOut(nil)
        AppActivation.restoreAccessoryIfNeeded()
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        onFinished()
        return false
    }

    private func makeWindow() -> NSWindow {
        let hosting = NSHostingController(
            rootView: WelcomeView(catalog: catalog, onFinished: onFinished)
        )
        let window = NSWindow(contentViewController: hosting)
        window.title = "Welcome to Zoomie"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.center()
        return window
    }
}
