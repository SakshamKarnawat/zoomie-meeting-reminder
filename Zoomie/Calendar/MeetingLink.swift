import Foundation

enum MeetingLink {
    static func url(eventURL: URL?, notes: String?, location: String?) -> URL? {
        if let eventURL, isHTTP(eventURL) { return eventURL }
        if let found = firstKnown(in: location) { return found }
        if let found = firstKnown(in: notes) { return found }
        if let found = firstHTTP(in: location) { return found }
        if let found = firstHTTP(in: notes) { return found }
        return nil
    }

    private static let knownHosts = [
        "zoom.us",
        "meet.google.com",
        "teams.microsoft.com",
        "teams.live.com",
        "facetime.apple.com",
        "webex.com"
    ]

    private static func isHTTP(_ url: URL) -> Bool {
        let scheme = url.scheme?.lowercased()
        return scheme == "https" || scheme == "http"
    }

    private static func isKnown(_ url: URL) -> Bool {
        guard isHTTP(url), let host = url.host?.lowercased() else { return false }
        return knownHosts.contains { host == $0 || host.hasSuffix(".\($0)") }
    }

    private static func firstKnown(in text: String?) -> URL? {
        urls(in: text).first { isKnown($0) }
    }

    private static func firstHTTP(in text: String?) -> URL? {
        urls(in: text).first { isHTTP($0) }
    }

    private static func urls(in text: String?) -> [URL] {
        guard let text, !text.isEmpty else { return [] }
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return []
        }
        let range = NSRange(text.startIndex..., in: text)
        return detector.matches(in: text, options: [], range: range).compactMap(\.url)
    }
}
