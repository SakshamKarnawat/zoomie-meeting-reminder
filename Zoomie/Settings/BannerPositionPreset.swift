import Foundation

enum BannerPositionPreset: String, CaseIterable, Identifiable {
    case top
    case upperCenter
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .top: "Top"
        case .upperCenter: "Upper-center"
        case .custom: "Custom"
        }
    }

    var fromTop: Double? {
        switch self {
        case .top: 0
        case .upperCenter: 0.22
        case .custom: nil
        }
    }
}
