import Foundation

enum MutedTitle {
    static let defaultList = "busy, blocked, focus, hold, ooo"

    static func tokens(from list: String) -> [String] {
        list.split { $0 == "," || $0 == "\n" || $0 == ";" }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    static func matches(_ title: String, tokens: [String]) -> Bool {
        let haystack = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !haystack.isEmpty else { return false }
        for raw in tokens {
            let token = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !token.isEmpty else { continue }
            if token.contains(where: { $0.isWhitespace }) {
                if haystack.contains(token) { return true }
                continue
            }
            if wholeWord(token, in: haystack) { return true }
        }
        return false
    }

    private static func wholeWord(_ token: String, in haystack: String) -> Bool {
        guard let regex = try? NSRegularExpression(
            pattern: "\\b\(NSRegularExpression.escapedPattern(for: token))\\b",
            options: []
        ) else {
            return haystack == token
        }
        let range = NSRange(haystack.startIndex..., in: haystack)
        return regex.firstMatch(in: haystack, options: [], range: range) != nil
    }
}
