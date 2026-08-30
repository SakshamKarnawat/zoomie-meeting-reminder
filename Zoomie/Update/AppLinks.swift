import Foundation

enum AppLinks {
    static let repository = "SakshamKarnawat/zoomie-meeting-reminder"
    static let latestReleaseAPI = URL(string: "https://api.github.com/repos/\(repository)/releases/latest")!
    static let installScript = URL(string: "https://raw.githubusercontent.com/\(repository)/main/install.sh")!

    static var installShellCommand: String {
        "curl -fsSL \(installScript.absoluteString) | bash"
    }
}
