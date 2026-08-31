import SwiftUI

struct GoogleAccountSection: View {
    var google: GoogleCalendarService
    let afterChange: () -> Void

    var body: some View {
        Section {
            if !GoogleClientConfig.isConfigured {
                Text("Add a Desktop OAuth client ID from your GCP project to GoogleClientConfig, or set GoogleClientID in the app Info.plist.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            } else if google.isBusy {
                ProgressView("Talking to Google…")
            } else if google.isSignedIn {
                LabeledContent("Signed in", value: google.email ?? "Google")
                Button("Disconnect Google", role: .destructive, action: disconnect)
            } else {
                Button("Connect Google…", action: connect)
            }
            if let errorMessage = google.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Google Calendar")
        } footer: {
            Text("Signs in with Google Calendar API. Independent of Apple Calendar. If the same calendar is also in Calendar.app, Zoomie keeps one copy of each meeting.")
        }
    }

    private func connect() {
        Task {
            await google.signIn()
            afterChange()
        }
    }

    private func disconnect() {
        Task {
            await google.signOut()
            afterChange()
        }
    }
}
