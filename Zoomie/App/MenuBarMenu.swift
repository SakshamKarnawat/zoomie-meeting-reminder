import SwiftUI

struct MenuBarMenu: View {
    @Bindable var settings: SettingsStore
    let nextEvent: () -> UpcomingEvent?
    let joinEvent: (URL) -> Void
    let openSettings: () -> Void
    let previewBanner: () -> Void
    let syncCalendars: () -> Void
    let openAbout: () -> Void
    let updateApp: () -> Void
    let quit: () -> Void

    var body: some View {
        NextEventMenuSection(load: nextEvent, join: joinEvent)
        Divider()
        SettingsOpenButton(open: openSettings)
        Button("Test Now", action: previewBanner)
        Button("Sync Calendars Now", action: syncCalendars)
        Toggle("Launch at Login", isOn: $settings.launchAtLogin)
        Divider()
        Button("About Zoomie…", action: openAbout)
        Button("Update Zoomie", action: updateApp)
        Divider()
        Button("Quit", action: quit)
    }
}
