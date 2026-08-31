import Foundation

struct GoogleEventDate: Decodable, Equatable {
    let date: String?
    let dateTime: String?

    var isAllDay: Bool {
        date != nil && dateTime == nil
    }

    func resolvedDate() -> Date? {
        if let dateTime, let parsed = Self.parseDateTime(dateTime) {
            return parsed
        }
        if let date, let parsed = Self.parseAllDay(date) {
            return parsed
        }
        return nil
    }

    static func parseDateTime(_ value: String) -> Date? {
        let withFraction = ISO8601DateFormatter()
        withFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = withFraction.date(from: value) { return date }
        let plain = ISO8601DateFormatter()
        plain.formatOptions = [.withInternetDateTime]
        return plain.date(from: value)
    }

    static func parseAllDay(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: value)
    }
}
