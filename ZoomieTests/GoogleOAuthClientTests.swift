import Foundation
import Testing
@testable import Zoomie

struct GoogleOAuthClientTests {
    @Test func authorizationURLEncodesLoopbackAndSkipsPrompt() throws {
        let url = GoogleOAuthClient.authorizationURL(
            redirect: "http://127.0.0.1:9004",
            state: "abc",
            challenge: "def"
        )
        let query = try #require(url.query)
        #expect(query.contains("redirect_uri=http%3A//127.0.0.1%3A9004"))
        #expect(query.contains("code_challenge_method=S256"))
        #expect(query.contains("access_type=offline"))
        #expect(!query.contains("prompt="))
        #expect(query.contains("openid"))
        #expect(!query.contains("client_secret"))
    }
}
