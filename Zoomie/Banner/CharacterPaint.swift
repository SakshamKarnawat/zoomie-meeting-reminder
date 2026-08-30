import SwiftUI

enum CharacterPaint {
    static func gradient(for color: Color) -> LinearGradient {
        LinearGradient(
            colors: [
                mix(color, toward: .white, amount: 0.30),
                color,
                mix(color, toward: .black, amount: 0.22)
            ],
            startPoint: UnitPoint(x: 0.26, y: 0.10),
            endPoint: UnitPoint(x: 0.84, y: 0.94)
        )
    }

    static func plate(for color: Color) -> Color {
        let luma = StoredColor.luminance(of: color)
        if luma > 0.55 {
            return mix(color, toward: Color(red: 0.14, green: 0.12, blue: 0.10), amount: 0.70)
        }
        return mix(color, toward: Color(red: 0.97, green: 0.94, blue: 0.88), amount: 0.58)
    }

    static func mix(_ color: Color, toward other: Color, amount: Double) -> Color {
        let t = min(max(amount, 0), 1)
        guard
            let a = NSColor(color).usingColorSpace(.sRGB),
            let b = NSColor(other).usingColorSpace(.sRGB)
        else {
            return color
        }
        return Color(
            red: a.redComponent + (b.redComponent - a.redComponent) * t,
            green: a.greenComponent + (b.greenComponent - a.greenComponent) * t,
            blue: a.blueComponent + (b.blueComponent - a.blueComponent) * t
        )
    }
}
