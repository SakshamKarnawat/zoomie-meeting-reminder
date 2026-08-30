import SwiftUI

struct CalendarToggleRow: View {
    @Bindable var settings: SettingsStore
    let calendar: CalendarDescriptor

    var body: some View {
        Toggle(isOn: isEnabled) {
            Label {
                Text(calendar.title)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(calendar.color)
            }
        }
    }

    private var isEnabled: Binding<Bool> {
        Binding(
            get: { settings.isCalendarEnabled(calendar.id) },
            set: { settings.setCalendar(calendar.id, enabled: $0) }
        )
    }
}
