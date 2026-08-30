import SwiftUI

struct CharacterColorSection: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        Section("Character color") {
            HStack(spacing: 8) {
                ForEach(CharacterColorSwatch.allCases) { swatch in
                    CharacterColorButton(
                        swatch: swatch,
                        isSelected: StoredColor.hex(from: settings.characterColor) == StoredColor.hex(from: swatch.color),
                        select: { settings.characterColor = swatch.color }
                    )
                }
            }
            ColorPicker("Custom color", selection: $settings.characterColor, supportsOpacity: false)
            Text("Applies to Cat and Corgi. Custom images keep their own colors.")
                .foregroundStyle(.secondary)
        }
    }
}
