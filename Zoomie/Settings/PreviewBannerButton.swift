import SwiftUI

struct PreviewBannerButton: View {
    let preview: () -> Void

    var body: some View {
        Button("Test Now", systemImage: "play.fill", action: preview)
            .help("Fly the banner with your current settings. No calendar event needed.")
    }
}
