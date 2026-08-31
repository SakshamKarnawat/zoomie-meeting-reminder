import Foundation

enum GoogleClientConfig {
    static let scope = "https://www.googleapis.com/auth/calendar.readonly email"

    static let bakedInClientID = "254340622701-1co5lneloh2bqur9vsovkmficnka34ec.apps.googleusercontent.com"

    static var clientID: String {
        let fromPlist = (Bundle.main.object(forInfoDictionaryKey: "GoogleClientID") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !fromPlist.isEmpty { return fromPlist }
        return bakedInClientID.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static var isConfigured: Bool {
        !clientID.isEmpty
    }
}
