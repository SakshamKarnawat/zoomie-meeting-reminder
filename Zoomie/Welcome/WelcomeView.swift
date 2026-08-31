import SwiftUI

struct WelcomeView: View {
    var catalog: EventCatalog
    let onFinished: () -> Void
    @State private var secretDraft = ""
    @State private var appleDenied = false

    var body: some View {
        VStack(alignment: .leading, spacing: Design.welcomeSpacing) {
            HStack(alignment: .top, spacing: 14) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: Design.welcomeIconSide, height: Design.welcomeIconSide)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Welcome to Zoomie")
                        .font(.title2)
                        .bold()
                    Text("A banner flies by before your meetings. Choose a calendar to start — you can add the other later in Settings.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if catalog.google.isSigningIn {
                GoogleSignInProgressView(google: catalog.google, onCancel: cancelGoogle)
            } else {
                VStack(spacing: 10) {
                    WelcomeSourceButton(
                        title: "Apple Calendar",
                        subtitle: "Calendars already on this Mac",
                        systemImage: "calendar",
                        action: connectApple
                    )
                    WelcomeSourceButton(
                        title: "Google Calendar",
                        subtitle: "Gmail and Google Calendar",
                        systemImage: "globe",
                        action: connectGoogle
                    )
                }

                if !GoogleClientConfig.hasClientSecret {
                    SecureField("Desktop client secret", text: $secretDraft)
                }

                if appleDenied {
                    Text("Zoomie needs Calendar access in System Settings to use Apple Calendar.")
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Open Calendar settings", action: SystemSettingsLink.openCalendarsPrivacy)
                }

                if let errorMessage = catalog.google.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Button("Not now", action: onFinished)
                    .buttonStyle(.plain)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Design.welcomePadding)
        .frame(width: Design.welcomeWidth)
    }

    private func connectApple() {
        Task {
            appleDenied = false
            let granted = await catalog.apple.requestAccess()
            if granted {
                onFinished()
            } else {
                appleDenied = true
            }
        }
    }

    private func connectGoogle() {
        Task {
            do {
                if !secretDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    try GoogleClientSecretStore.save(secretDraft)
                }
            } catch {
                catalog.google.errorMessage = (error as? LocalizedError)?.errorDescription
                    ?? error.localizedDescription
                return
            }
            secretDraft = ""
            await catalog.google.signIn()
            if catalog.google.isSignedIn {
                onFinished()
            }
        }
    }

    private func cancelGoogle() {
        catalog.google.cancelSignIn()
    }
}
