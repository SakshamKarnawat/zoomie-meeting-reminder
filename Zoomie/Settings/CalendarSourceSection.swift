import SwiftUI

struct CalendarSourceSection: View {
    var apple: CalendarService
    let afterChange: () -> Void

    var body: some View {
        Section {
            if apple.hasAccess {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Apple Calendar is local.")
                    Text("iCloud, Outlook, and any Google calendars you added under System Settings → Internet Accounts show up here after they appear in Calendar.app.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button("Open Internet Accounts…", action: SystemSettingsLink.openInternetAccounts)
            } else {
                Text("Optional. Zoomie can also use calendars already on this Mac.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Connect Apple Calendar…", action: connect)
                if apple.isDenied {
                    Text("Enable Zoomie in System Settings → Privacy & Security → Calendars.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Open Calendar settings", action: SystemSettingsLink.openCalendarsPrivacy)
                }
            }
        } header: {
            Text("Apple Calendar")
        } footer: {
            Text("Zoomie reads Calendar.app through EventKit. This is separate from Connect Google below.")
        }
    }

    private func connect() {
        Task {
            _ = await apple.requestAccess()
            afterChange()
        }
    }
}
