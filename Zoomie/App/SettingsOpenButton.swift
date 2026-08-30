import SwiftUI

struct SettingsOpenButton: View {
    let open: () -> Void

    var body: some View {
        Button("Settings…", action: open)
    }
}
