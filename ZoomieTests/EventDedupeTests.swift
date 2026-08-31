import Foundation
import Testing
@testable import Zoomie

struct EventDedupeTests {
    @Test func keepsAppleWhenTitlesAndStartMatch() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        let apple = TimedEvent(
            id: "a",
            title: "Standup",
            startDate: start,
            endDate: start.addingTimeInterval(1800),
            isAllDay: false,
            calendarID: "apple-cal",
            userDeclined: false,
            eventURL: nil,
            notes: nil,
            location: nil
        )
        let google = TimedEvent(
            id: "g",
            title: "standup",
            startDate: start.addingTimeInterval(20),
            endDate: start.addingTimeInterval(1800),
            isAllDay: false,
            calendarID: "google:primary",
            userDeclined: false,
            eventURL: nil,
            notes: nil,
            location: nil
        )
        let merged = EventDedupe.merge(apple: [apple], google: [google])
        #expect(merged.count == 1)
        #expect(merged[0].id == "a")
    }

    @Test func prefersGoogleJoinURL() {
        let start = Date(timeIntervalSince1970: 1_800_000_000)
        let apple = TimedEvent(
            id: "a",
            title: "Standup",
            startDate: start,
            endDate: nil,
            isAllDay: false,
            calendarID: "apple-cal",
            userDeclined: false,
            eventURL: nil,
            notes: nil,
            location: nil
        )
        let google = TimedEvent(
            id: "g",
            title: "Standup",
            startDate: start,
            endDate: nil,
            isAllDay: false,
            calendarID: "google:primary",
            userDeclined: false,
            eventURL: URL(string: "https://meet.google.com/abc-defg-hij"),
            notes: nil,
            location: nil
        )
        let merged = EventDedupe.merge(apple: [apple], google: [google])
        #expect(merged.count == 1)
        #expect(merged[0].id == "g")
    }
}
