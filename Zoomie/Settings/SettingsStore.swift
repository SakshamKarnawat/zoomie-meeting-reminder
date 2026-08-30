import Foundation

@MainActor
@Observable
final class SettingsStore {
    private enum Keys {
        static let character = "character"
        static let customImageBookmark = "customImageBookmark"
        static let customImagePath = "customImagePath"
        static let theme = "theme"
        static let leadTime = "leadTimeMinutes"
        static let pingAtStart = "pingAtStart"
        static let messageTemplate = "messageTemplate"
        static let font = "font"
        static let disabledCalendarIDs = "disabledCalendarIDs"
        static let launchAtLogin = "launchAtLogin"
        static let bannerPosition = "bannerPosition"
        static let bannerFromTop = "bannerFromTop"
    }

    private let defaults: UserDefaults

    var character: CharacterChoice {
        didSet { defaults.set(character.rawValue, forKey: Keys.character) }
    }

    var customImageBookmark: Data? {
        didSet { defaults.set(customImageBookmark, forKey: Keys.customImageBookmark) }
    }

    var customImagePath: String? {
        didSet { defaults.set(customImagePath, forKey: Keys.customImagePath) }
    }

    var theme: BannerTheme {
        didSet { defaults.set(theme.rawValue, forKey: Keys.theme) }
    }

    var leadTime: LeadTimeOption {
        didSet {
            defaults.set(leadTime.rawValue, forKey: Keys.leadTime)
            onSchedulingRelevantChange?()
        }
    }

    var pingAtStart: Bool {
        didSet {
            defaults.set(pingAtStart, forKey: Keys.pingAtStart)
            onSchedulingRelevantChange?()
        }
    }

    var messageTemplate: String {
        didSet { defaults.set(messageTemplate, forKey: Keys.messageTemplate) }
    }

    var font: BannerFontChoice {
        didSet { defaults.set(font.rawValue, forKey: Keys.font) }
    }

    var disabledCalendarIDs: Set<String> {
        didSet {
            defaults.set(Array(disabledCalendarIDs), forKey: Keys.disabledCalendarIDs)
            onSchedulingRelevantChange?()
        }
    }

    var bannerPosition: BannerPositionPreset {
        didSet { defaults.set(bannerPosition.rawValue, forKey: Keys.bannerPosition) }
    }

    var bannerFromTop: Double {
        didSet { defaults.set(bannerFromTop, forKey: Keys.bannerFromTop) }
    }

    var resolvedFromTop: Double {
        bannerPosition.fromTop ?? min(max(bannerFromTop, 0), 1)
    }

    var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            guard !isApplyingLoginItem else { return }
            applyLaunchAtLogin()
        }
    }

    var loginItemError: String?
    private var isApplyingLoginItem = false
    var onSchedulingRelevantChange: (() -> Void)?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let storedCharacter = defaults.string(forKey: Keys.character) ?? ""
        character = CharacterChoice(rawValue: storedCharacter) ?? .cat

        customImageBookmark = defaults.data(forKey: Keys.customImageBookmark)
        customImagePath = defaults.string(forKey: Keys.customImagePath)

        let storedTheme = defaults.string(forKey: Keys.theme) ?? ""
        theme = BannerTheme(rawValue: storedTheme) ?? .classic

        let storedLead = defaults.object(forKey: Keys.leadTime) as? Int
        leadTime = LeadTimeOption(rawValue: storedLead ?? LeadTimeOption.five.rawValue) ?? .five

        pingAtStart = defaults.object(forKey: Keys.pingAtStart) as? Bool ?? false

        let storedTemplate = defaults.string(forKey: Keys.messageTemplate)
        messageTemplate = storedTemplate ?? MessageTemplate.defaultTemplate

        let storedFont = defaults.string(forKey: Keys.font) ?? ""
        font = BannerFontChoice(rawValue: storedFont) ?? .rounded

        let storedDisabled = defaults.stringArray(forKey: Keys.disabledCalendarIDs) ?? []
        disabledCalendarIDs = Set(storedDisabled)

        let storedPosition = defaults.string(forKey: Keys.bannerPosition) ?? ""
        bannerPosition = BannerPositionPreset(rawValue: storedPosition) ?? .top
        bannerFromTop = defaults.object(forKey: Keys.bannerFromTop) as? Double ?? 0

        launchAtLogin = LoginItemService.isEnabled
        defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
    }

    func isCalendarEnabled(_ id: String) -> Bool {
        !disabledCalendarIDs.contains(id)
    }

    func setCalendar(_ id: String, enabled: Bool) {
        if enabled {
            disabledCalendarIDs.remove(id)
        } else {
            disabledCalendarIDs.insert(id)
        }
    }

    func setCustomImage(bookmark: Data, path: String) {
        customImageBookmark = bookmark
        customImagePath = path
        character = .custom
    }

    func clearCustomImage() {
        customImageBookmark = nil
        customImagePath = nil
        if character == .custom {
            character = .cat
        }
    }

    private func applyLaunchAtLogin() {
        isApplyingLoginItem = true
        defer { isApplyingLoginItem = false }
        do {
            try LoginItemService.setEnabled(launchAtLogin)
            loginItemError = nil
        } catch {
            loginItemError = error.localizedDescription
        }
        let actual = LoginItemService.isEnabled
        if actual != launchAtLogin {
            launchAtLogin = actual
        }
    }
}
