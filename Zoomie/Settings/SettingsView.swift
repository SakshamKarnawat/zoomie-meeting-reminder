import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    var calendarService: CalendarService
    let previewBanner: () -> Void
    let syncCalendars: () -> Void
    var updates: AppUpdateService

    var body: some View {
        Form {
            Section {
                PreviewBannerButton(preview: previewBanner)
            } footer: {
                Text("Flies the banner with your current look. No meeting required.")
            }

            CharacterPickerSection(settings: settings)
            CharacterColorSection(settings: settings)
            ThemePickerSection(settings: settings)
            BannerPositionSection(
                settings: settings,
                screenSize: NSScreen.main?.visibleFrame.size ?? CGSize(width: 1440, height: 900)
            )

            Section("Timing") {
                Picker("Lead time", selection: $settings.leadTime) {
                    ForEach(LeadTimeOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                Toggle("Also ping at meeting start", isOn: $settings.pingAtStart)
            }

            CalendarSyncSection(settings: settings, syncNow: syncCalendars)

            Section("Message") {
                TextField("Template", text: $settings.messageTemplate, axis: .vertical)
                    .lineLimit(2...)
                Text("Use {event} for the title and {mins} for minutes remaining.")
                    .foregroundStyle(.secondary)
            }

            Section("Font") {
                Picker("Font", selection: $settings.font) {
                    ForEach(BannerFontChoice.allCases) { choice in
                        Text(choice.title)
                            .font(choice.sampleFont)
                            .tag(choice)
                    }
                }
            }

            CalendarListSection(settings: settings, calendars: calendarService.calendars)
            IgnoreTitlesSection(settings: settings)

            Section("General") {
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                if let loginItemError = settings.loginItemError {
                    Text(loginItemError)
                        .foregroundStyle(.red)
                }
            }

            AboutSection(updates: updates)
        }
        .formStyle(.grouped)
        .frame(minWidth: 480, minHeight: 560)
        .task {
            calendarService.refreshCalendars()
        }
    }
}

#Preview {
    SettingsView(
        settings: SettingsStore(),
        calendarService: CalendarService(),
        previewBanner: {},
        syncCalendars: {},
        updates: AppUpdateService()
    )
}
