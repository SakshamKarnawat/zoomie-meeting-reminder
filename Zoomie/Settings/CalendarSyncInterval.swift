import Foundation

enum CalendarSyncInterval: Int, CaseIterable, Identifiable {
    case fourHours = 4
    case sixHours = 6
    case twelveHours = 12
    case twentyFourHours = 24

    var id: Int { rawValue }

    var title: String {
        "\(rawValue) hours"
    }

    var timeInterval: TimeInterval {
        TimeInterval(rawValue * 60 * 60)
    }
}
