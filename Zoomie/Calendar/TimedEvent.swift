import Foundation

struct TimedEvent: Equatable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
    let calendarID: String
    let userDeclined: Bool
    let eventURL: URL?
    let notes: String?
    let location: String?

    var joinURL: URL? {
        MeetingLink.url(eventURL: eventURL, notes: notes, location: location)
    }

    func asUpcoming(now: Date = .now) -> UpcomingEvent? {
        if let endDate, endDate <= now { return nil }
        return UpcomingEvent(title: title, startDate: startDate, joinURL: joinURL)
    }
}
