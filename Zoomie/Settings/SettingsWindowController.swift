import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let settings: SettingsStore
    private let catalog: EventCatalog
    private let previewBanner: () -> Void
    private let syncCalendars: () -> Void
    private let updates: AppUpdateService

    init(
        settings: SettingsStore,
        catalog: EventCatalog,
        previewBanner: @escaping () -> Void,
        syncCalendars: @escaping () -> Void,
        updates: AppUpdateService
    ) {
        self.settings = settings
        self.catalog = catalog
        self.previewBanner = previewBanner
        self.syncCalendars = syncCalendars
        self.updates = updates
        super.init(window: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is unused")
    }

    func showSettings() {
        if window == nil {
            window = makeWindow()
        }
        catalog.apple.refreshCalendars()
        catalog.bump()
        AppActivation.bringToFront(window!)
        Task {
            await catalog.google.refresh()
            catalog.bump()
        }
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        AppActivation.restoreAccessoryIfNeeded()
        return false
    }

    private func makeWindow() -> NSWindow {
        let hosting = NSHostingController(
            rootView: SettingsView(
                settings: settings,
                catalog: catalog,
                previewBanner: previewBanner,
                syncCalendars: syncCalendars,
                updates: updates
            )
        )
        let window = NSWindow(contentViewController: hosting)
        window.title = "Zoomie Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 720))
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("ZoomieSettings")
        window.center()
        return window
    }
}
