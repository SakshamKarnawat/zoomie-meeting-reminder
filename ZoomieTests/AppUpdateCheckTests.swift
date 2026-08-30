import Foundation
import Testing
@testable import Zoomie

struct AppUpdateCheckTests {
    @Test func missingInstallDateMeansAvailable() {
        let release = GitHubLatestRelease(publishedAt: Date(), assets: [])
        #expect(AppUpdateCheck.status(release: release, installedAt: nil) == .available)
    }

    @Test func newerZipIsAvailable() {
        let installed = Date(timeIntervalSince1970: 100)
        let release = GitHubLatestRelease(
            publishedAt: Date(timeIntervalSince1970: 200),
            assets: [.init(name: "Zoomie.zip", updatedAt: Date(timeIntervalSince1970: 400))]
        )
        #expect(AppUpdateCheck.status(release: release, installedAt: installed) == .available)
    }

    @Test func olderZipIsUpToDate() {
        let installed = Date(timeIntervalSince1970: 500)
        let release = GitHubLatestRelease(
            publishedAt: Date(timeIntervalSince1970: 200),
            assets: [.init(name: "Zoomie.zip", updatedAt: Date(timeIntervalSince1970: 200))]
        )
        #expect(AppUpdateCheck.status(release: release, installedAt: installed) == .upToDate)
    }
}
