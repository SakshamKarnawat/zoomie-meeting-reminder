import SwiftUI

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    var catalog: EventCatalog
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

            CalendarSourceSection(apple: catalog.apple, afterChange: syncCalendars)
            if catalog.apple.hasAccess {
                CalendarListSection(
                    settings: settings,
                    title: "Apple calendars",
                    calendars: catalog.appleCalendars,
                    emptyLabel: "Add iCloud or Outlook in System Settings → Internet Accounts so they appear in Calendar.app, then use Sync Now."
                )
            }
            GoogleAccountSection(google: catalog.google, afterChange: syncCalendars)
            if catalog.google.isSignedIn {
                CalendarListSection(
                    settings: settings,
                    title: "Google calendars",
                    calendars: catalog.googleCalendars,
                    emptyLabel: "No Google calendars on this account. Check the account in Google Calendar, then Sync Now."
                )
            }
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
            catalog.apple.refreshCalendars()
            await catalog.google.refresh()
            catalog.bump()
        }
    }
}

#Preview {
    SettingsView(
        settings: SettingsStore(),
        catalog: EventCatalog(apple: CalendarService(), google: GoogleCalendarService()),
        previewBanner: {},
        syncCalendars: {},
        updates: AppUpdateService()
    )
}
