import SwiftUI

struct GoogleAccountSection: View {
    var google: GoogleCalendarService
    let afterChange: () -> Void
    @State private var secretDraft = ""

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
                GoogleSignInProgressView(google: google, onCancel: cancel)
            } else {
                if !GoogleClientConfig.hasClientSecret {
                    SecureField("Desktop client secret", text: $secretDraft)
                }
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
            do {
                if !secretDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    try GoogleClientSecretStore.save(secretDraft)
                }
            } catch {
                google.errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                return
            }
            secretDraft = ""
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
