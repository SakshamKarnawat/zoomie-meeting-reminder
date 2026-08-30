import SwiftUI

struct EmptyCalendarsLabel: View {
    var body: some View {
        ContentUnavailableView(
            "No calendars",
            systemImage: "calendar.badge.exclamationmark",
            description: Text("Add iCloud, Google, or Outlook in System Settings → Internet Accounts so they appear in Calendar.app, then use Sync Now.")
        )
    }
}
