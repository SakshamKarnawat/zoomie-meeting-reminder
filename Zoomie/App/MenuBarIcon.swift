import AppKit

enum MenuBarIcon {
    static let symbolName = "pawprint.fill"

    static var templateImage: NSImage {
        let symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Zoomie")
            ?? NSImage(size: NSSize(width: 18, height: 18))
        let image = symbol.copy() as? NSImage ?? symbol
        image.isTemplate = true
        image.size = NSSize(width: 18, height: 18)
        return image
    }
}
