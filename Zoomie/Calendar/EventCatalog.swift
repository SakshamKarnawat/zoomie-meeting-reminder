import Foundation

@MainActor
@Observable
final class EventCatalog {
    let apple: CalendarService
    let google: GoogleCalendarService
    private(set) var snapshotID = 0

    init(apple: CalendarService, google: GoogleCalendarService) {
        self.apple = apple
        self.google = google
    }

    var appleCalendars: [CalendarDescriptor] { apple.calendars }
    var googleCalendars: [CalendarDescriptor] { google.calendars }

    func reload() async {
        apple.reload()
        await google.refresh()
        bump()
    }

    func timedEvents(disabledCalendarIDs: Set<String>, from now: Date) -> [TimedEvent] {
        EventDedupe.merge(
            apple: apple.timedEvents(disabledCalendarIDs: disabledCalendarIDs, from: now),
            google: google.timedEvents(disabledCalendarIDs: disabledCalendarIDs, from: now)
        )
    }

    func nextUpcomingEvent(
        disabledCalendarIDs: Set<String>,
        mutedTitleTokens: [String],
        now: Date = .now
    ) -> UpcomingEvent? {
        let events = timedEvents(disabledCalendarIDs: disabledCalendarIDs, from: now)
        for event in events {
            guard EventQualifying.isQualifying(
                title: event.title,
                isAllDay: event.isAllDay,
                userDeclined: event.userDeclined,
                calendarIdentifier: event.calendarID,
                disabledCalendarIDs: disabledCalendarIDs,
                mutedTitleTokens: mutedTitleTokens
            ) else { continue }
            if let upcoming = event.asUpcoming(now: now) {
                return upcoming
            }
        }
        return nil
    }

    func bump() {
        snapshotID = apple.snapshotID + google.snapshotID
    }
}
