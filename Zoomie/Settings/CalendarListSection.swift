import SwiftUI

struct CalendarListSection: View {
    @Bindable var settings: SettingsStore
    let title: String
    let calendars: [CalendarDescriptor]
    var emptyLabel: String

    var body: some View {
        Section(title) {
            if calendars.isEmpty {
                EmptyCalendarsLabel(message: emptyLabel)
            } else {
                ForEach(calendars) { calendar in
                    CalendarToggleRow(settings: settings, calendar: calendar)
                }
            }
        }
    }
}
