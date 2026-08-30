import AppKit
import EventKit
import Foundation

@MainActor
final class EventScheduler {
    private let calendarService: CalendarService
    private let settings: SettingsStore
    private let banner: BannerController

    private var timer: Timer?
    private var queue: [ScheduledFire] = []
    private var deliveredKeys: Set<String> = []
    private var observers: [NSObjectProtocol] = []

    init(calendarService: CalendarService, settings: SettingsStore, banner: BannerController) {
        self.calendarService = calendarService
        self.settings = settings
        self.banner = banner
    }

    func start() {
        registerWakeHandler()
        registerStoreChangeHandler()
        reschedule()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        for observer in observers {
            NSWorkspace.shared.notificationCenter.removeObserver(observer)
            NotificationCenter.default.removeObserver(observer)
        }
        observers.removeAll()
    }

    func reschedule() {
        timer?.invalidate()
        timer = nil
        queue.removeAll()

        let now = Date.now
        pruneDelivered()

        let fires = upcomingFires(after: now)
        guard let next = fires.first else {
            scheduleRefresh(after: Design.emptyCalendarRefresh)
            return
        }

        if next.fireDate <= now {
            beginCluster(from: fires)
            return
        }

        scheduleTimer(at: next.fireDate)
    }

    private func upcomingFires(after now: Date) -> [ScheduledFire] {
        let events = calendarService.upcomingEvents(
            disabledCalendarIDs: settings.disabledCalendarIDs,
            from: now
        )

        var fires: [ScheduledFire] = []
        for event in events {
            fires.append(contentsOf: firesForEvent(event, now: now))
        }

        return fires.sorted { lhs, rhs in
            if lhs.fireDate == rhs.fireDate {
                return lhs.startDate < rhs.startDate
            }
            return lhs.fireDate < rhs.fireDate
        }
    }

    private func firesForEvent(_ event: EKEvent, now: Date) -> [ScheduledFire] {
        let declined = calendarService.userDeclined(event)
        let calendarID = event.calendar.calendarIdentifier
        guard EventQualifying.isQualifying(
            title: event.title,
            isAllDay: event.isAllDay,
            userDeclined: declined,
            calendarIdentifier: calendarID,
            disabledCalendarIDs: settings.disabledCalendarIDs,
            mutedTitleTokens: settings.mutedTitleTokens
        ) else {
            return []
        }

        guard let title = event.title else { return [] }
        guard let start = event.startDate, start > now else { return [] }
        let identifier = event.eventIdentifier ?? "\(calendarID)|\(start.timeIntervalSince1970)|\(title)"

        var result: [ScheduledFire] = []
        let leadMinutes = settings.leadTime.rawValue
        let leadDate = start.addingTimeInterval(-TimeInterval(leadMinutes) * 60)

        if !deliveredKeys.contains("\(identifier)|\(ScheduledFire.Kind.lead.rawValue)") {
            if leadDate > now {
                result.append(
                    ScheduledFire(
                        eventIdentifier: identifier,
                        title: title,
                        startDate: start,
                        fireDate: leadDate,
                        minutesUntilStart: leadMinutes,
                        kind: .lead
                    )
                )
            } else {
                result.append(
                    ScheduledFire(
                        eventIdentifier: identifier,
                        title: title,
                        startDate: start,
                        fireDate: now,
                        minutesUntilStart: max(0, Int((start.timeIntervalSince(now) / 60).rounded())),
                        kind: .lead
                    )
                )
            }
        }

        if settings.pingAtStart {
            let startFire = ScheduledFire(
                eventIdentifier: identifier,
                title: title,
                startDate: start,
                fireDate: start,
                minutesUntilStart: 0,
                kind: .start
            )
            if !deliveredKeys.contains(startFire.deliveryKey) {
                result.append(startFire)
            }
        }

        return result
    }

    private func beginCluster(from fires: [ScheduledFire]) {
        guard let first = fires.first else {
            reschedule()
            return
        }

        let cluster = fires.filter { candidate in
            candidate.fireDate.timeIntervalSince(first.fireDate) <= Design.clusterWindow
        }
        queue = Array(cluster.dropFirst())
        present(first)
    }

    private func present(_ fire: ScheduledFire) {
        deliveredKeys.insert(fire.deliveryKey)
        let minutes = fire.kind == .start ? 0 : fire.minutesUntilStart
        let message = MessageTemplate.render(
            settings.messageTemplate,
            event: fire.title,
            minutes: minutes
        )
        let image = settings.customImageBookmark.flatMap(CustomImageStore.loadImage)

        banner.show(message: message, settings: settings, customImage: image) { [weak self] in
            self?.presentNextOrReschedule()
        }
    }

    private func presentNextOrReschedule() {
        if !queue.isEmpty {
            let next = queue.removeFirst()
            present(next)
            return
        }
        reschedule()
    }

    private func scheduleTimer(at date: Date) {
        timer?.invalidate()
        let scheduled = Timer(fire: date, interval: 0, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.handleTimerFire()
            }
        }
        RunLoop.main.add(scheduled, forMode: .common)
        timer = scheduled
    }

    private func scheduleRefresh(after interval: TimeInterval) {
        timer?.invalidate()
        let scheduled = Timer(timeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.reschedule()
            }
        }
        RunLoop.main.add(scheduled, forMode: .common)
        timer = scheduled
    }

    private func handleTimerFire() {
        timer = nil
        let now = Date.now
        let fires = upcomingFires(after: now.addingTimeInterval(-1))
        beginCluster(from: fires)
    }

    private func registerWakeHandler() {
        let observer = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.timer?.invalidate()
                self?.timer = nil
                self?.reschedule()
            }
        }
        observers.append(observer)
    }

    private func registerStoreChangeHandler() {
        let observer = NotificationCenter.default.addObserver(
            forName: .EKEventStoreChanged,
            object: calendarService.store,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.calendarService.refreshCalendars()
                self?.reschedule()
            }
        }
        observers.append(observer)
    }

    private func pruneDelivered() {
        if deliveredKeys.count > 200 {
            deliveredKeys.removeAll()
        }
    }
}
