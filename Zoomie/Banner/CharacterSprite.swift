import SwiftUI

struct CharacterSprite: View {
    let choice: CharacterChoice
    let color: Color
    let customImage: NSImage?

    var body: some View {
        if let customImage, choice == .custom {
            Image(nsImage: customImage)
                .resizable()
                .scaledToFit()
                .frame(width: Design.customCharacterSide, height: Design.customCharacterSide)
                .accessibilityHidden(true)
        } else {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                DrawnCharacter(choice: choice == .custom ? .cat : choice, color: color, wag: sin(t * 7))
                    .offset(y: sin(t * 5.5) * Design.characterBob)
            }
            .frame(width: Design.customCharacterSide, height: Design.customCharacterSide)
            .accessibilityHidden(true)
        }
    }
}
