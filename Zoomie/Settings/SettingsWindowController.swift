import AppKit
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController, NSWindowDelegate {
    private let settings: SettingsStore
    private let calendarService: CalendarService
    private let previewBanner: () -> Void

    init(settings: SettingsStore, calendarService: CalendarService, previewBanner: @escaping () -> Void) {
        self.settings = settings
        self.calendarService = calendarService
        self.previewBanner = previewBanner
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
        calendarService.refreshCalendars()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        sender.orderOut(nil)
        NSApp.setActivationPolicy(.accessory)
        return false
    }

    private func makeWindow() -> NSWindow {
        let hosting = NSHostingController(
            rootView: SettingsView(
                settings: settings,
                calendarService: calendarService,
                previewBanner: previewBanner
            )
        )
        let window = NSWindow(contentViewController: hosting)
        window.title = "Zoomie Settings"
        window.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        window.setContentSize(NSSize(width: 520, height: 640))
        window.isReleasedWhenClosed = false
        window.delegate = self
        window.setFrameAutosaveName("ZoomieSettings")
        window.center()
        return window
    }
}
