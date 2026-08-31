import AppKit
import Foundation

@MainActor
final class AppRuntime {
    let settings: SettingsStore
    let catalog: EventCatalog
    let banner: BannerController
    let scheduler: EventScheduler
    let updates: AppUpdateService
    let calendarSync: CalendarSync
    private(set) lazy var settingsWindow = SettingsWindowController(
        settings: settings,
        catalog: catalog,
        previewBanner: { [unowned self] in self.previewBanner() },
        syncCalendars: { [unowned self] in self.syncCalendars() },
        updates: updates
    )
    private(set) lazy var aboutWindow = AboutWindowController(updates: updates)

    private var didStart = false

    init() {
        let settings = SettingsStore()
        let apple = CalendarService()
        let google = GoogleCalendarService()
        let catalog = EventCatalog(apple: apple, google: google)
        let banner = BannerController()
        self.settings = settings
        self.catalog = catalog
        self.banner = banner
        self.updates = AppUpdateService()
        self.scheduler = EventScheduler(
            catalog: catalog,
            settings: settings,
            banner: banner
        )
        self.calendarSync = CalendarSync(
            catalog: catalog,
            settings: settings,
            onRefreshed: { [scheduler] in
                scheduler.reschedule()
            }
        )
        settings.onSchedulingRelevantChange = { [scheduler] in
            scheduler.reschedule()
        }
        settings.onCalendarSyncIntervalChange = { [calendarSync] in
            calendarSync.restart()
        }
    }

    func start() async {
        guard !didStart else { return }
        didStart = true

        let granted = await catalog.apple.requestAccess()
        guard granted else {
            catalog.apple.presentDeniedAlertAndTerminate()
            return
        }

        scheduler.start()
        calendarSync.start()
    }

    func previewBanner() {
        let message = MessageTemplate.render(
            settings.messageTemplate,
            event: MessageTemplate.previewEventTitle,
            minutes: settings.leadTime.rawValue
        )
        let image = settings.customImageBookmark.flatMap(CustomImageStore.loadImage)
        banner.preview(message: message, settings: settings, customImage: image)
    }

    func openSettings() {
        settingsWindow.showSettings()
    }

    func openAbout() {
        aboutWindow.showAbout()
    }

    func nextUpcomingEvent() -> UpcomingEvent? {
        catalog.nextUpcomingEvent(
            disabledCalendarIDs: settings.disabledCalendarIDs,
            mutedTitleTokens: settings.mutedTitleTokens
        )
    }

    func joinMeeting(_ url: URL) {
        NSWorkspace.shared.open(url)
    }

    func updateApp() {
        updates.installLatest()
    }

    func syncCalendars() {
        calendarSync.syncNow()
    }
}
