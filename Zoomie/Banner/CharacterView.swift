import SwiftUI

struct CharacterView: View {
    let choice: CharacterChoice
    let customImage: NSImage?

    var body: some View {
        if let customImage, choice == .custom {
            Image(nsImage: customImage)
                .resizable()
                .scaledToFit()
                .frame(width: Design.customCharacterSide, height: Design.customCharacterSide)
                .accessibilityHidden(true)
        } else {
            Text(choice.emoji ?? CharacterChoice.duck.emoji ?? "🦆")
                .font(.system(size: Design.characterPointSize))
                .accessibilityHidden(true)
        }
    }
}
