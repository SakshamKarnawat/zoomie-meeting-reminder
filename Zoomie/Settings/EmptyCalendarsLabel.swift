import SwiftUI

struct EmptyCalendarsLabel: View {
    var message: String

    var body: some View {
        ContentUnavailableView(
            "No calendars",
            systemImage: "calendar.badge.exclamationmark",
            description: Text(message)
        )
    }
}
