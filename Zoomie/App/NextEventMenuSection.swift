import SwiftUI

struct NextEventMenuSection: View {
    let load: () -> UpcomingEvent?
    let join: (URL) -> Void
    @State private var event: UpcomingEvent?

    var body: some View {
        Group {
            if let event {
                Text(UpcomingEventLabel.text(title: event.title, start: event.startDate, now: .now))
                if let url = event.joinURL {
                    Button("Join", action: { join(url) })
                }
            } else {
                Text("No upcoming events")
            }
        }
        .onAppear {
            event = load()
        }
    }
}
