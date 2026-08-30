import SwiftUI

struct CharacterBackdrop: View {
    let color: Color

    var body: some View {
        let plate = CharacterPaint.plate(for: color)
        Ellipse()
            .fill(
                RadialGradient(
                    colors: [
                        plate.opacity(Design.characterBackdropCenterOpacity),
                        plate.opacity(Design.characterBackdropEdgeOpacity),
                        Color.clear
                    ],
                    center: .center,
                    startRadius: Design.customCharacterSide * 0.10,
                    endRadius: Design.customCharacterSide * 0.58
                )
            )
            .frame(
                width: Design.customCharacterSide * 1.12,
                height: Design.customCharacterSide * 0.96
            )
            .offset(y: 6)
            .blur(radius: Design.characterBackdropBlur)
            .allowsHitTesting(false)
    }
}
