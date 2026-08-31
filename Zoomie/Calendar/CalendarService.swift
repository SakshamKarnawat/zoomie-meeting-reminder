import EventKit
import SwiftUI

@MainActor
@Observable
final class CalendarService {
    let store = EKEventStore()
    var calendars: [CalendarDescriptor] = []
    private(set) var snapshotID = 0
    private var isReloading = false

    var hasAccess: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    var isDenied: Bool {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .denied, .restricted: true
        default: false
        }
    }

    func requestAccess() async -> Bool {
        if hasAccess {
            refreshCalendars()
            return true
        }

        do {
            let granted = try await store.requestFullAccessToEvents()
            if granted {
                refreshCalendars()
            }
            return granted
        } catch {
            return false
        }
    }

    func reload() {
        guard !isReloading else { return }
        isReloading = true
        store.reset()
        store.refreshSourcesIfNecessary()
        refreshCalendars()
        snapshotID += 1
        isReloading = false
    }

    func refreshCalendars() {
        calendars = store.calendars(for: .event).map { calendar in
            CalendarDescriptor(
                id: calendar.calendarIdentifier,
                title: calendar.title,
                color: Color(nsColor: calendar.color),
                source: .apple
            )
        }
        .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    func upcomingEvents(disabledCalendarIDs: Set<String>, from now: Date) -> [EKEvent] {
        let end = now.addingTimeInterval(TimeInterval(Design.lookAheadDays * 24 * 60 * 60))
        let enabledCalendars = store.calendars(for: .event).filter { calendar in
            !disabledCalendarIDs.contains(calendar.calendarIdentifier)
        }
        guard !enabledCalendars.isEmpty else { return [] }

        let predicate = store.predicateForEvents(withStart: now, end: end, calendars: enabledCalendars)
        return store.events(matching: predicate)
    }

    func timedEvents(disabledCalendarIDs: Set<String>, from now: Date) -> [TimedEvent] {
        upcomingEvents(disabledCalendarIDs: disabledCalendarIDs, from: now).compactMap { event in
            TimedEvent(event: event, declined: userDeclined(event))
        }
    }

    func nextUpcomingEvent(
        disabledCalendarIDs: Set<String>,
        mutedTitleTokens: [String],
        now: Date = .now
    ) -> UpcomingEvent? {
        let events = timedEvents(disabledCalendarIDs: disabledCalendarIDs, from: now)
            .sorted { $0.startDate < $1.startDate }
        for event in events {
            let qualifies = EventQualifying.isQualifying(
                title: event.title,
                isAllDay: event.isAllDay,
                userDeclined: event.userDeclined,
                calendarIdentifier: event.calendarID,
                disabledCalendarIDs: disabledCalendarIDs,
                mutedTitleTokens: mutedTitleTokens
            )
            guard qualifies, let upcoming = event.asUpcoming(now: now) else { continue }
            return upcoming
        }
        return nil
    }

    func userDeclined(_ event: EKEvent) -> Bool {
        guard let attendees = event.attendees else { return false }
        return attendees.contains { attendee in
            attendee.isCurrentUser && attendee.participantStatus == .declined
        }
    }

    func presentDeniedAlertAndTerminate() {
        let alert = NSAlert()
        alert.messageText = "Calendar Access Required"
        alert.informativeText = "Enable Zoomie in System Settings > Privacy & Security > Calendars, then open Zoomie again."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
        NSApp.terminate(nil)
    }
}
