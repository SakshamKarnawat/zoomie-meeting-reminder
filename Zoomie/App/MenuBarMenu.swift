import SwiftUI

struct MenuBarMenu: View {
    @Bindable var settings: SettingsStore
    let previewBanner: () -> Void
    let quit: () -> Void

    var body: some View {
        SettingsOpenButton()
        Button("Test Now", action: previewBanner)
        Toggle("Launch at Login", isOn: $settings.launchAtLogin)
        Divider()
        Button("Quit", action: quit)
    }
}
