import SwiftUI

struct ThemePickerSection: View {
    @Bindable var settings: SettingsStore

    var body: some View {
        Section("Banner theme") {
            Picker("Theme", selection: $settings.theme) {
                ForEach(BannerTheme.allCases) { theme in
                    Text(theme.title).tag(theme)
                }
            }

            ThemeSwatchRow(theme: settings.theme)
        }
    }
}
