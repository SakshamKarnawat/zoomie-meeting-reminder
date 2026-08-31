import SwiftUI

struct CalendarSourceSection: View {
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("Apple Calendar is local.")
                Text("iCloud, Outlook, and any Google calendars you added under System Settings → Internet Accounts show up here after they appear in Calendar.app.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button("Open Internet Accounts…", action: SystemSettingsLink.openInternetAccounts)
        } header: {
            Text("Apple Calendar")
        } footer: {
            Text("Zoomie reads Calendar.app through EventKit. This is separate from Connect Google below.")
        }
    }
}
