import SwiftUI

struct MenuBarMenu: View {
    @Bindable var settings: SettingsStore
    var calendarService: CalendarService
    let nextEvent: () -> UpcomingEvent?
    let joinEvent: (URL) -> Void
    let openSettings: () -> Void
    let previewBanner: () -> Void
    let syncCalendars: () -> Void
    let openAbout: () -> Void
    let updateApp: () -> Void
    let quit: () -> Void
    @State private var menuSnapshot = 0

    var body: some View {
        NextEventMenuSection(
            load: nextEvent,
            join: joinEvent,
            refreshToken: calendarService.snapshotID + menuSnapshot
        )
        Divider()
        SettingsOpenButton(open: openSettings)
        Button("Test Now", action: previewBanner)
        Button("Sync Calendars Now") {
            syncCalendars()
            menuSnapshot += 1
        }
        Toggle("Launch at Login", isOn: $settings.launchAtLogin)
        Divider()
        Button("About Zoomie…", action: openAbout)
        Button("Update Zoomie", action: updateApp)
        Divider()
        Button("Quit", action: quit)
    }
}
