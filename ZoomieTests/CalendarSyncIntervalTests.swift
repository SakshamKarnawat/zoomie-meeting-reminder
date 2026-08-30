import Testing
@testable import Zoomie

struct CalendarSyncIntervalTests {
    @Test func sixHoursIsDefaultRawValue() {
        #expect(CalendarSyncInterval.sixHours.rawValue == 6)
        #expect(CalendarSyncInterval.sixHours.timeInterval == 6 * 60 * 60)
    }

    @Test func fourHoursIsFourHours() {
        #expect(CalendarSyncInterval.fourHours.timeInterval == 4 * 60 * 60)
    }
}
