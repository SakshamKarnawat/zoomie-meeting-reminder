import Foundation

enum CharacterChoice: String, CaseIterable, Identifiable {
    case cat
    case corgi
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cat: "Cat"
        case .corgi: "Corgi"
        case .custom: "Custom"
        }
    }

    var emoji: String? {
        switch self {
        case .cat: "🐈"
        case .corgi: "🐕"
        case .custom: nil
        }
    }
}
