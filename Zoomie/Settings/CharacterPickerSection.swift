import SwiftUI

struct CharacterPickerSection: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        Section("Character") {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 72), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(CharacterChoice.allCases.filter { $0 != .custom }) { choice in
                    CharacterChoiceButton(
                        choice: choice,
                        isSelected: settings.character == choice,
                        select: { select(choice) }
                    )
                }
            }

            Button("Custom", systemImage: "photo", action: pickCustomImage)

            if settings.character == .custom, let path = settings.customImagePath {
                LabeledContent("Image") {
                    Text(path)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
                Button("Clear custom image", action: settings.clearCustomImage)
            }
        }
    }

    private func select(_ choice: CharacterChoice) {
        settings.character = choice
    }

    private func pickCustomImage() {
        guard let picked = CustomImageStore.pickImage() else { return }
        settings.setCustomImage(bookmark: picked.bookmark, path: picked.path)
    }
}
