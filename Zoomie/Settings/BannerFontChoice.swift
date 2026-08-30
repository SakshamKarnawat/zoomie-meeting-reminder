import SwiftUI

enum BannerFontChoice: String, CaseIterable, Identifiable {
    case systemDefault
    case rounded
    case serif
    case monospaced
    case condensed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .systemDefault: "System"
        case .rounded: "Rounded"
        case .serif: "Serif"
        case .monospaced: "Mono"
        case .condensed: "Condensed"
        }
    }

    var font: Font {
        switch self {
        case .systemDefault: .system(.title2, design: .default).bold()
        case .rounded: .system(.title2, design: .rounded).bold()
        case .serif: .system(.title2, design: .serif).bold()
        case .monospaced: .system(.title2, design: .monospaced).bold()
        case .condensed: .system(.title2, design: .default).width(.condensed).bold()
        }
    }

    var sampleFont: Font {
        switch self {
        case .systemDefault: .system(.body, design: .default)
        case .rounded: .system(.body, design: .rounded)
        case .serif: .system(.body, design: .serif)
        case .monospaced: .system(.body, design: .monospaced)
        case .condensed: .system(.body, design: .default).width(.condensed)
        }
    }
}
