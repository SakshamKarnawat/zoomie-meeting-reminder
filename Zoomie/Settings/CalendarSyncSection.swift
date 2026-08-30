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
            Text("Background pull from accounts already in Calendar. Default is 6 hours. Changes from Calendar.app still apply as soon as EventKit notifies Zoomie.")
        }
    }
}
