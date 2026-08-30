import SwiftUI

struct UpdateActionsView: View {
    var updates: AppUpdateService

    var body: some View {
        Button("Check for Updates…", action: check)
            .disabled(isBusy)
        Button("Update Zoomie", action: updates.installLatest)
            .disabled(updates.status == .installing)
        Text(updates.status.message)
            .foregroundStyle(.secondary)
    }

    private var isBusy: Bool {
        updates.status == .checking || updates.status == .installing
    }

    private func check() {
        Task { await updates.checkForUpdates() }
    }
}
