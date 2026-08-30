import Foundation

enum EventQualifying {
    static func isQualifying(
        title: String?,
        isAllDay: Bool,
        userDeclined: Bool,
        calendarIdentifier: String,
        disabledCalendarIDs: Set<String>,
        mutedTitleTokens: [String] = []
    ) -> Bool {
        guard let title else { return false }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard !isAllDay else { return false }
        guard !userDeclined else { return false }
        guard !disabledCalendarIDs.contains(calendarIdentifier) else { return false }
        guard !MutedTitle.matches(trimmed, tokens: mutedTitleTokens) else { return false }
        return true
    }

    static func userDeclined(isCurrentUserAndDeclined: Bool) -> Bool {
        isCurrentUserAndDeclined
    }
}
