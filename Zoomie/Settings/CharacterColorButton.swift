import SwiftUI

struct CharacterColorButton: View {
    let swatch: CharacterColorSwatch
    let isSelected: Bool
    let select: () -> Void

    var body: some View {
        Button(action: select) {
            Circle()
                .fill(swatch.color)
                .frame(width: 22, height: 22)
                .overlay {
                    Circle()
                        .strokeBorder(isSelected ? Color.primary : Color.secondary.opacity(0.35), lineWidth: isSelected ? 2 : 1)
                }
        }
        .buttonStyle(.plain)
        .frame(minWidth: Design.pickerHitSize, minHeight: Design.pickerHitSize)
        .accessibilityLabel(swatch.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
