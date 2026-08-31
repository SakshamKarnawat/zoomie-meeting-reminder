import Foundation
import Testing
@testable import Zoomie

struct GoogleEventDateTests {
    @Test func parsesOffsetDateTime() {
        let parsed = GoogleEventDate.parseDateTime("2026-09-01T10:30:00+05:30")
        #expect(parsed != nil)
    }

    @Test func parsesAllDay() {
        let parsed = GoogleEventDate.parseAllDay("2026-09-01")
        #expect(parsed != nil)
    }

    @Test func allDayFlag() {
        let date = GoogleEventDate(date: "2026-09-01", dateTime: nil)
        #expect(date.isAllDay)
        let timed = GoogleEventDate(date: nil, dateTime: "2026-09-01T10:00:00Z")
        #expect(!timed.isAllDay)
    }
}
