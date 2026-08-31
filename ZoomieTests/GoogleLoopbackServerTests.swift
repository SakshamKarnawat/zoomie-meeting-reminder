import Foundation
import Testing
@testable import Zoomie

struct GoogleLoopbackServerTests {
    @Test func parsesRedirectFromHTTPRequest() {
        let request = "GET /?code=abc&state=xyz HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n"
        let url = GoogleLoopbackServer.redirectURL(from: request)
        #expect(url?.query?.contains("code=abc") == true)
        #expect(url.map(GoogleLoopbackServer.isOAuthCallback) == true)
    }

    @Test func ignoresFavicon() {
        let request = "GET /favicon.ico HTTP/1.1\r\nHost: 127.0.0.1\r\n\r\n"
        let url = GoogleLoopbackServer.redirectURL(from: request)
        #expect(url.map(GoogleLoopbackServer.isOAuthCallback) != true)
    }
}
