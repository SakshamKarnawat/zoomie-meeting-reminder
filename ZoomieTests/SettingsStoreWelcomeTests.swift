import Foundation
import Testing
@testable import Zoomie

@MainActor
struct SettingsStoreWelcomeTests {
    @Test func welcomeFlagPersists() {
        let suite = "app.zoomie.Zoomie.tests.welcome.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let store = SettingsStore(defaults: defaults)
        #expect(!store.hasCompletedWelcome)
        store.hasCompletedWelcome = true
        let again = SettingsStore(defaults: defaults)
        #expect(again.hasCompletedWelcome)
        defaults.removePersistentDomain(forName: suite)
    }
}
