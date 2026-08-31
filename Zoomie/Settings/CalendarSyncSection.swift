import SwiftUI

struct CalendarSyncSection: View {
    @Bindable var settings: SettingsStore
    let syncNow: () -> Void

    var body: some View {
        Section {
            Picker("Refresh calendars", selection: $settings.calendarSyncInterval) {
                ForEach(CalendarSyncInterval.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            Button("Sync Now", action: syncNow)
        } footer: {
            Text("Pulls Apple Calendar locally and Google Calendar if you are signed in. Default is 6 hours. Calendar.app edits still apply as soon as EventKit notifies Zoomie.")
        }
    }
}
