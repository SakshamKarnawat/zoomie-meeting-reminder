import AppKit
import Foundation

struct InstalledBrowser: Identifiable, Hashable {
    let id: String
    let name: String
    let appURL: URL

    func open(_ url: URL) {
        NSWorkspace.shared.open(
            [url],
            withApplicationAt: appURL,
            configuration: NSWorkspace.OpenConfiguration()
        )
    }
}
