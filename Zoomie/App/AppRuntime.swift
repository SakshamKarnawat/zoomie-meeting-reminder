import Foundation

@MainActor
final class AppRuntime {
    let settings: SettingsStore
    let calendarService: CalendarService
    let banner: BannerController
    let scheduler: EventScheduler
    private(set) lazy var settingsWindow = SettingsWindowController(
        settings: settings,
        calendarService: calendarService,
        previewBanner: { [unowned self] in self.previewBanner() }
    )

    private var didStart = false

    init() {
        let settings = SettingsStore()
        let calendarService = CalendarService()
        let banner = BannerController()
        self.settings = settings
        self.calendarService = calendarService
        self.banner = banner
        self.scheduler = EventScheduler(
            calendarService: calendarService,
            settings: settings,
            banner: banner
        )
        settings.onSchedulingRelevantChange = { [scheduler] in
            scheduler.reschedule()
        }
    }

    func start() async {
        guard !didStart else { return }
        didStart = true

        let granted = await calendarService.requestAccess()
        guard granted else {
            calendarService.presentDeniedAlertAndTerminate()
            return
        }

        scheduler.start()
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
}
