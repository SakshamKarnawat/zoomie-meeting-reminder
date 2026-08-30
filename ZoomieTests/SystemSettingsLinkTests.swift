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
}
