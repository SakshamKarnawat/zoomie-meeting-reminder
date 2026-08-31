import AppKit

enum SystemSettingsLink {
    static let internetAccountsURLs = [
        "x-apple.systempreferences:com.apple.Accounts-Settings.extension",
        "x-apple.systempreferences:com.apple.preferences.internetaccounts"
    ]

    static let calendarsPrivacyURLs = [
        "x-apple.systempreferences:com.apple.Settings.PrivacySecurity.extension?Privacy_Calendars",
        "x-apple.systempreferences:com.apple.preference.security?Privacy_Calendars"
    ]

    static func openInternetAccounts() {
        openFirst(internetAccountsURLs)
    }

    static func openCalendarsPrivacy() {
        openFirst(calendarsPrivacyURLs)
    }

    private static func openFirst(_ candidates: [String]) {
        for candidate in candidates {
            guard let url = URL(string: candidate) else { continue }
            if NSWorkspace.shared.open(url) { return }
        }
    }
}
