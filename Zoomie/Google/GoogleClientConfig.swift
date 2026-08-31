import Foundation

enum GoogleClientConfig {
    static let scope = "openid email https://www.googleapis.com/auth/calendar.readonly"

    /// Desktop OAuth client ID from the GCP project.
    static let bakedInClientID = "254340622701-1co5lneloh2bqur9vsovkmficnka34ec.apps.googleusercontent.com"

    /// Desktop clients include a secret in the downloaded JSON. Google’s token
    /// endpoint often requires it even with PKCE. Leave empty to skip sending it.
    static let bakedInClientSecret = ""

    static var clientID: String {
        firstNonEmpty(
            Bundle.main.object(forInfoDictionaryKey: "GoogleClientID") as? String,
            bakedInClientID
        )
    }

    static var clientSecret: String {
        firstNonEmpty(
            Bundle.main.object(forInfoDictionaryKey: "GoogleClientSecret") as? String,
            bakedInClientSecret
        )
    }

    static var isConfigured: Bool {
        !clientID.isEmpty
    }

    private static func firstNonEmpty(_ plist: String?, _ baked: String) -> String {
        let fromPlist = plist?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromPlist.isEmpty { return fromPlist }
        return baked.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
