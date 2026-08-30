import SwiftUI

struct EmptyCalendarsLabel: View {
    var body: some View {
        ContentUnavailableView(
            "No calendars",
            systemImage: "calendar.badge.exclamationmark",
            description: Text("Link iCloud or Google in System Settings > Internet Accounts, then reopen Zoomie.")
        )
    }
}
