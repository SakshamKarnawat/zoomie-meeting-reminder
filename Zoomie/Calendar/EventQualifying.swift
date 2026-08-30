import Foundation

enum EventQualifying {
    static func isQualifying(
        title: String?,
        isAllDay: Bool,
        userDeclined: Bool,
        calendarIdentifier: String,
        disabledCalendarIDs: Set<String>
    ) -> Bool {
        guard let title else { return false }
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !isAllDay else { return false }
        guard !userDeclined else { return false }
        guard !disabledCalendarIDs.contains(calendarIdentifier) else { return false }
        return true
    }

    static func userDeclined(isCurrentUserAndDeclined: Bool) -> Bool {
        isCurrentUserAndDeclined
    }
}
