import AppKit
import Foundation

enum InstalledBrowsers {
    static let knownBundleIDs: Set<String> = [
        "com.apple.Safari",
        "com.apple.SafariTechnologyPreview",
        "com.google.Chrome",
        "com.google.Chrome.canary",
        "com.google.Chrome.beta",
        "org.mozilla.firefox",
        "org.mozilla.firefoxdeveloperedition",
        "org.mozilla.nightly",
        "com.brave.Browser",
        "com.microsoft.edgemac",
        "com.microsoft.edgemac.Beta",
        "com.operasoftware.Opera",
        "com.vivaldi.Vivaldi",
        "company.thebrowser.Browser",
        "app.zen-browser.zen",
        "com.kagi.orion",
        "org.chromium.Chromium"
    ]

    static func isKnown(_ bundleID: String) -> Bool {
        knownBundleIDs.contains(bundleID)
    }

    static func list() -> [InstalledBrowser] {
        let probe = URL(string: "https://accounts.google.com")!
        let apps = NSWorkspace.shared.urlsForApplications(toOpen: probe)
        var seen = Set<String>()
        var browsers: [InstalledBrowser] = []
        for appURL in apps {
            guard let bundle = Bundle(url: appURL),
                  let bundleID = bundle.bundleIdentifier,
                  isKnown(bundleID),
                  seen.insert(bundleID).inserted
            else { continue }
            let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                ?? appURL.deletingPathExtension().lastPathComponent
            browsers.append(InstalledBrowser(id: bundleID, name: name, appURL: appURL))
        }
        return browsers.sorted { lhs, rhs in
            if lhs.id == "com.apple.Safari" { return true }
            if rhs.id == "com.apple.Safari" { return false }
            return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
        }
    }
}
