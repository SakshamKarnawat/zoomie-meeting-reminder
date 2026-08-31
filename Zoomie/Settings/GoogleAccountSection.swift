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
            } else if google.isSignedIn {
                LabeledContent("Signed in", value: google.email ?? "Google")
                Button("Disconnect Google", role: .destructive, action: disconnect)
            } else if google.isSigningIn {
                ProgressView("Waiting for Google in your browser…")
                Text("Finish the Google window, then come back. Cancel if the browser shows an error.")
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button("Cancel", action: cancel)
            } else {
                Button("Connect Google…", action: connect)
            }
            if let errorMessage = google.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
                    .fixedSize(horizontal: false, vertical: true)
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

    private func cancel() {
        google.cancelSignIn()
    }

    private func disconnect() {
        Task {
            await google.signOut()
            afterChange()
        }
    }
}
