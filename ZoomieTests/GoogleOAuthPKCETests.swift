import Foundation
import Testing
@testable import Zoomie

struct GoogleOAuthPKCETests {
    @Test func verifierIsURLSafe() {
        let verifier = GoogleOAuthPKCE.makeVerifier()
        #expect(!verifier.isEmpty)
        #expect(!verifier.contains("+"))
        #expect(!verifier.contains("/"))
        #expect(!verifier.contains("="))
    }

    @Test func challengeIsStableForVerifier() {
        let verifier = "abc"
        #expect(GoogleOAuthPKCE.challenge(for: verifier) == GoogleOAuthPKCE.challenge(for: verifier))
    }
}
