import AppKit

enum AppActivation {
    static func bringToFront(_ window: NSWindow) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    static func restoreAccessoryIfNeeded() {
        let keepRegular = NSApp.windows.contains { window in
            window.isVisible && window.styleMask.contains(.titled) && window.canBecomeKey
        }
        if !keepRegular {
            NSApp.setActivationPolicy(.accessory)
        }
    }
}
