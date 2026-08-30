import Foundation

enum AppUpdateCheck {
    static func status(release: GitHubLatestRelease, installedAt: Date?) -> AppUpdateStatus {
        guard let installedAt else { return .available }
        let slack: TimeInterval = 60
        return release.zipUpdatedAt > installedAt.addingTimeInterval(slack) ? .available : .upToDate
    }
}
