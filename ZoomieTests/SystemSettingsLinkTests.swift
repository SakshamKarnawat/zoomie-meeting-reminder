import Foundation
import Testing
@testable import Zoomie

struct SystemSettingsLinkTests {
    @Test func internetAccountsURLsParse() {
        #expect(!SystemSettingsLink.internetAccountsURLs.isEmpty)
        for string in SystemSettingsLink.internetAccountsURLs {
            #expect(URL(string: string) != nil)
        }
    }

    @Test func calendarsPrivacyURLsParse() {
        #expect(!SystemSettingsLink.calendarsPrivacyURLs.isEmpty)
        for string in SystemSettingsLink.calendarsPrivacyURLs {
            #expect(URL(string: string) != nil)
        }
    }
}
