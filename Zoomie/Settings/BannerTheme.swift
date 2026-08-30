import SwiftUI

enum BannerTheme: String, CaseIterable, Identifiable {
    case classic
    case midnight
    case sunset
    case mint
    case bubblegum

    var id: String { rawValue }

    var title: String {
        switch self {
        case .classic: "Classic"
        case .midnight: "Midnight"
        case .sunset: "Sunset"
        case .mint: "Mint"
        case .bubblegum: "Bubblegum"
        }
    }

    var foreground: Color {
        switch self {
        case .classic: Color(red: 0.12, green: 0.14, blue: 0.18)
        case .midnight: .white
        case .sunset: .white
        case .mint: Color(red: 0.08, green: 0.28, blue: 0.20)
        case .bubblegum: Color(red: 0.42, green: 0.10, blue: 0.22)
        }
    }
}
