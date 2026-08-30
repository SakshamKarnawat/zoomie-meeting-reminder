enum AppUpdateStatus: Equatable {
    case idle
    case checking
    case upToDate
    case available
    case installing
    case failed(String)

    var message: String {
        switch self {
        case .idle: "Checks GitHub for a newer Zoomie.zip."
        case .checking: "Checking…"
        case .upToDate: "You’re on the latest build."
        case .available: "A newer build is available."
        case .installing: "Updating. Zoomie will quit and reopen."
        case .failed(let detail): detail
        }
    }
}
