import SwiftUI

struct BannerPositionSection: View {
    @Bindable var settings: SettingsStore
    let screenSize: CGSize

    var body: some View {
        Section("Banner position") {
            BannerPositionPreview(fromTop: settings.resolvedFromTop, screenSize: screenSize)

            Picker("Position", selection: $settings.bannerPosition) {
                ForEach(BannerPositionPreset.allCases) { preset in
                    Text(preset.title).tag(preset)
                }
            }
            .pickerStyle(.segmented)

            if settings.bannerPosition == .custom {
                LabeledContent("From top") {
                    Slider(value: $settings.bannerFromTop, in: 0...0.7)
                }
            }

            Text("\(Int((settings.resolvedFromTop * 100).rounded()))% from top")
                .foregroundStyle(.secondary)
        }
    }
}
