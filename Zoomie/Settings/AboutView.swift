import SwiftUI

struct AboutView: View {
    var updates: AppUpdateService

    var body: some View {
        VStack(spacing: 12) {
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)
            Text("Zoomie")
                .font(.title2.weight(.semibold))
            Text("Version \(AppVersion.display)")
                .foregroundStyle(.secondary)
            UpdateActionsView(updates: updates)
                .padding(.top, 4)
        }
        .padding(24)
        .frame(width: 320)
        .task {
            await updates.checkForUpdates()
        }
    }
}
