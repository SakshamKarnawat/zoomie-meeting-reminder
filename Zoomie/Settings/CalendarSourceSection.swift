import SwiftUI

struct CalendarSourceSection: View {
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("Zoomie only reads Apple Calendar.")
                Text("Add iCloud, Google, or Outlook in System Settings → Internet Accounts. Those calendars then appear in Calendar.app, and Zoomie reads them from there. It cannot sign in to those services itself.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Button("Open Internet Accounts…", action: SystemSettingsLink.openInternetAccounts)
        } header: {
            Text("Where events come from")
        } footer: {
            Text("A meeting that exists only in a browser or another app will not appear until it is on a calendar in Calendar.app. Sync Now refreshes accounts already there; it does not add new ones.")
        }
    }
}
