import Foundation

enum CharacterChoice: String, CaseIterable, Identifiable {
    case duck
    case corgi
    case dino
    case pigeon
    case capybara
    case cat
    case custom

    var id: String { rawValue }

    var title: String {
        switch self {
        case .duck: "Duck"
        case .corgi: "Corgi"
        case .dino: "Dino"
        case .pigeon: "Pigeon"
        case .capybara: "Capybara"
        case .cat: "Cat"
        case .custom: "Custom"
        }
    }

    var emoji: String? {
        switch self {
        case .duck: "🦆"
        case .corgi: "🐕"
        case .dino: "🦖"
        case .pigeon: "🕊️"
        case .capybara: "🐹"
        case .cat: "🐈"
        case .custom: nil
        }
    }
}
