import SwiftUI

enum CharacterColorSwatch: String, CaseIterable, Identifiable {
    case slate
    case ginger
    case black
    case cream
    case white
    case brown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .slate: "Slate"
        case .ginger: "Ginger"
        case .black: "Black"
        case .cream: "Cream"
        case .white: "White"
        case .brown: "Brown"
        }
    }

    var color: Color {
        switch self {
        case .slate: Color(red: 0.35, green: 0.36, blue: 0.40)
        case .ginger: Color(red: 0.86, green: 0.52, blue: 0.22)
        case .black: Color(red: 0.12, green: 0.12, blue: 0.13)
        case .cream: Color(red: 0.93, green: 0.86, blue: 0.70)
        case .white: Color(red: 0.96, green: 0.96, blue: 0.95)
        case .brown: Color(red: 0.45, green: 0.28, blue: 0.16)
        }
    }
}
