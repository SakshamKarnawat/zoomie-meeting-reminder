import EventKit
import Foundation

extension TimedEvent {
    init?(event: EKEvent, declined: Bool) {
        guard let title = event.title, let start = event.startDate else { return nil }
        self.init(
            id: event.eventIdentifier ?? "\(event.calendar.calendarIdentifier)|\(start.timeIntervalSince1970)|\(title)",
            title: title,
            startDate: start,
            endDate: event.endDate,
            isAllDay: event.isAllDay,
            calendarID: event.calendar.calendarIdentifier,
            userDeclined: declined,
            eventURL: event.url,
            notes: event.notes,
            location: event.location
        )
    }

    init?(google dto: GoogleEventDTO, calendarID: String) {
        guard let title = dto.summary?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            return nil
        }
        guard let start = dto.start?.resolvedDate() else { return nil }
        self.init(
            id: dto.id ?? "\(calendarID)|\(start.timeIntervalSince1970)|\(title)",
            title: title,
            startDate: start,
            endDate: dto.end?.resolvedDate(),
            isAllDay: dto.start?.isAllDay ?? false,
            calendarID: calendarID,
            userDeclined: dto.userDeclined,
            eventURL: dto.eventURL,
            notes: dto.description,
            location: dto.location
        )
    }
}
