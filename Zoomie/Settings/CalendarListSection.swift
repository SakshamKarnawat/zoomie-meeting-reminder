import SwiftUI

struct CalendarListSection: View {
    @Bindable var settings: SettingsStore
    let calendars: [CalendarDescriptor]

    var body: some View {
        Section("Calendars") {
            if calendars.isEmpty {
                EmptyCalendarsLabel()
            } else {
                ForEach(calendars) { calendar in
                    CalendarToggleRow(settings: settings, calendar: calendar)
                }
            }
        }
    }
}
