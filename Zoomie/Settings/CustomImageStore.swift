import AppKit
import UniformTypeIdentifiers

enum CustomImageStore {
    static func pickImage() -> (bookmark: Data, path: String)? {
        let panel = NSOpenPanel()
        panel.title = "Choose a character image"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.png, .jpeg, .webP, .heic, .tiff, .gif]
        guard panel.runModal() == .OK, let url = panel.url else { return nil }

        do {
            let bookmark = try url.bookmarkData(
                options: [.withSecurityScope],
                includingResourceValuesForKeys: nil,
                relativeTo: nil
            )
            return (bookmark, url.path)
        } catch {
            return nil
        }
    }

    static func loadImage(fromBookmark data: Data) -> NSImage? {
        var isStale = false
        do {
            let url = try URL(
                resolvingBookmarkData: data,
                options: [.withSecurityScope],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
            let accessed = url.startAccessingSecurityScopedResource()
            defer {
                if accessed {
                    url.stopAccessingSecurityScopedResource()
                }
            }
            return NSImage(contentsOf: url)
        } catch {
            return nil
        }
    }
}
