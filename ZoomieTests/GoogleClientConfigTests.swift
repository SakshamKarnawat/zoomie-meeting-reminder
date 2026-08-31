import Foundation
import Testing
@testable import Zoomie

struct GoogleClientConfigTests {
    @Test func secretComesFromEnvKeyName() {
        #expect(GoogleClientConfig.environmentSecretKey == "ZOOMIE_GOOGLE_CLIENT_SECRET")
    }
}
