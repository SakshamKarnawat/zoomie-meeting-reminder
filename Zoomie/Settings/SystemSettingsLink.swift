import AppKit

enum SystemSettingsLink {
    static let internetAccountsURLs = [
        "x-apple.systempreferences:com.apple.Accounts-Settings.extension",
        "x-apple.systempreferences:com.apple.preferences.internetaccounts"
    ]

    static func openInternetAccounts() {
        for candidate in internetAccountsURLs {
            guard let url = URL(string: candidate) else { continue }
            if NSWorkspace.shared.open(url) { return }
        }
    }
}
