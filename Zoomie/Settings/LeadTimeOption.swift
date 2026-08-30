import Foundation

enum LeadTimeOption: Int, CaseIterable, Identifiable {
    case five = 5
    case ten = 10

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .five: "5 min"
        case .ten: "10 min"
        }
    }
}
