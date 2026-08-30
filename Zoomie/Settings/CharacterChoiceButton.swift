import SwiftUI

struct CharacterChoiceButton: View {
    let choice: CharacterChoice
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            VStack(spacing: 4) {
                Text(choice.emoji ?? "")
                    .font(.system(size: 28))
                Text(choice.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: Design.pickerHitSize, minHeight: Design.pickerHitSize)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.clear)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(isSelected ? Color.primary : Color.secondary.opacity(0.35), lineWidth: isSelected ? 2 : 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(choice.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
