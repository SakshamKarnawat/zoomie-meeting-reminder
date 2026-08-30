import Foundation

@MainActor
@Observable
final class AppUpdateService {
    var status: AppUpdateStatus = .idle

    func checkForUpdates() async {
        status = .checking
        do {
            var request = URLRequest(url: AppLinks.latestReleaseAPI)
            request.setValue("Zoomie/\(AppVersion.marketing)", forHTTPHeaderField: "User-Agent")
            request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
            let (data, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
                status = .failed("GitHub returned \(http.statusCode).")
                return
            }
            let release = try GitHubLatestRelease.decode(from: data)
            status = AppUpdateCheck.status(release: release, installedAt: AppVersion.installedAt)
        } catch {
            status = .failed("Could not reach GitHub.")
        }
    }

    func installLatest() {
        status = .installing
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = ["-lc", AppLinks.installShellCommand]
        do {
            try process.run()
        } catch {
            status = .failed(error.localizedDescription)
        }
    }
}
