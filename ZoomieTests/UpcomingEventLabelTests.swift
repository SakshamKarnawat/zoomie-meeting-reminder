import Foundation
import Testing
@testable import Zoomie

struct UpcomingEventLabelTests {
    @Test func usesMinutesWhenUnderAnHour() {
        let start = Date(timeIntervalSince1970: 3_600)
        let now = Date(timeIntervalSince1970: 3_600 - 12 * 60)
        #expect(UpcomingEventLabel.text(title: "Call", start: start, now: now) == "Call · in 12 min")
    }

    @Test func usesNowWhenStarted() {
        let start = Date(timeIntervalSince1970: 100)
        let now = Date(timeIntervalSince1970: 160)
        #expect(UpcomingEventLabel.text(title: "Call", start: start, now: now) == "Call · now")
    }
}
