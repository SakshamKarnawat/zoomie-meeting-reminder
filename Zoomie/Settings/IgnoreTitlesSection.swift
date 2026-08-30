import SwiftUI

struct IgnoreTitlesSection: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        Section("Ignore titles") {
            TextField("busy, blocked, focus…", text: $settings.mutedTitleList, axis: .vertical)
                .lineLimit(2...)
            Text("No banner when the title contains one of these as a whole word.")
                .foregroundStyle(.secondary)
        }
    }
}
