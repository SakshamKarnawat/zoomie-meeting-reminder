import Foundation

enum MessageTemplate {
    static let defaultTemplate = "{event} in {mins} min"
    static let previewEventTitle = "Zoomie preview"

    static func render(_ template: String, event: String, minutes: Int) -> String {
        let trimmed = template.trimmingCharacters(in: .whitespacesAndNewlines)
        let source = trimmed.isEmpty ? defaultTemplate : trimmed
        return source
            .replacing("{event}", with: event)
            .replacing("{mins}", with: String(minutes))
    }
}
