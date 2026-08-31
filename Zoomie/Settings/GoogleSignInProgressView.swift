import SwiftUI

struct GoogleSignInProgressView: View {
    var google: GoogleCalendarService
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressView("Waiting for Google…")
            Text("Open the sign-in link in a browser. After Google finishes, this window updates.")
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            if google.browsers.isEmpty {
                Text("No browsers found.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(google.browsers) { browser in
                    Button("Open in \(browser.name)") {
                        google.openAuthorization(in: browser)
                    }
                }
            }
            Button("Cancel", action: onCancel)
        }
    }
}
