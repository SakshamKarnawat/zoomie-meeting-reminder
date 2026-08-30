import SwiftUI

struct AboutSection: View {
    var updates: AppUpdateService

    var body: some View {
        Section("About") {
            LabeledContent("Version", value: AppVersion.display)
            UpdateActionsView(updates: updates)
        }
    }
}
