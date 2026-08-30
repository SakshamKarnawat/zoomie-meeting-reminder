import Testing
@testable import Zoomie

struct EventQualifyingTests {
    @Test func requiresTitle() {
        #expect(
            EventQualifying.isQualifying(
                title: nil,
                isAllDay: false,
                userDeclined: false,
                calendarIdentifier: "home",
                disabledCalendarIDs: []
            ) == false
        )
        #expect(
            EventQualifying.isQualifying(
                title: "   ",
                isAllDay: false,
                userDeclined: false,
                calendarIdentifier: "home",
                disabledCalendarIDs: []
            ) == false
        )
    }

    @Test func rejectsAllDayAndDeclined() {
        #expect(
            EventQualifying.isQualifying(
                title: "Holiday",
                isAllDay: true,
                userDeclined: false,
                calendarIdentifier: "home",
                disabledCalendarIDs: []
            ) == false
        )
        #expect(
            EventQualifying.isQualifying(
                title: "Skip me",
                isAllDay: false,
                userDeclined: true,
                calendarIdentifier: "work",
                disabledCalendarIDs: []
            ) == false
        )
    }

    @Test func rejectsDisabledCalendar() {
        #expect(
            EventQualifying.isQualifying(
                title: "Sync",
                isAllDay: false,
                userDeclined: false,
                calendarIdentifier: "work",
                disabledCalendarIDs: ["work"]
            ) == false
        )
    }

    @Test func acceptsTimedEnabledEvent() {
        #expect(
            EventQualifying.isQualifying(
                title: "Standup",
                isAllDay: false,
                userDeclined: false,
                calendarIdentifier: "work",
                disabledCalendarIDs: ["personal"]
            )
        )
    }
}
