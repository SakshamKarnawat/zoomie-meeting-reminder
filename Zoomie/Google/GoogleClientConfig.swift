import Foundation

enum GoogleClientConfig {
    static let scope = "openid email https://www.googleapis.com/auth/calendar.readonly"
    static let environmentSecretKey = "ZOOMIE_GOOGLE_CLIENT_SECRET"

    /// Desktop OAuth client ID from the GCP project. Not a secret.
    static let bakedInClientID = "254340622701-1co5lneloh2bqur9vsovkmficnka34ec.apps.googleusercontent.com"

    static var clientID: String {
        firstNonEmpty(
            Bundle.main.object(forInfoDictionaryKey: "GoogleClientID") as? String,
            bakedInClientID
        )
    }

    /// Release Info.plist (CI), then Keychain, then env. Never bake the secret into source.
    static var clientSecret: String {
        firstNonEmpty(
            Bundle.main.object(forInfoDictionaryKey: "GoogleClientSecret") as? String,
            GoogleClientSecretStore.load(),
            ProcessInfo.processInfo.environment[environmentSecretKey]
        )
    }

    static var hasClientSecret: Bool {
        !clientSecret.isEmpty
    }

    static var isConfigured: Bool {
        !clientID.isEmpty
    }

    private static func firstNonEmpty(_ values: String?...) -> String {
        for value in values {
            let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !trimmed.isEmpty { return trimmed }
        }
        return ""
    }
}
