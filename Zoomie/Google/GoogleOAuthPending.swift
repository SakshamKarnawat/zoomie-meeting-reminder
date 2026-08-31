import Foundation

final class GoogleOAuthPending: @unchecked Sendable {
    let authorizationURL: URL
    private let server: GoogleLoopbackServer
    private let redirect: String
    private let verifier: String
    private let state: String

    init(
        authorizationURL: URL,
        server: GoogleLoopbackServer,
        redirect: String,
        verifier: String,
        state: String
    ) {
        self.authorizationURL = authorizationURL
        self.server = server
        self.redirect = redirect
        self.verifier = verifier
        self.state = state
    }

    func waitForTokens() async throws -> GoogleTokens {
        let callback: URL
        do {
            callback = try await GoogleOAuthClient.firstResult {
                try await self.server.waitForRedirect()
            } timeout: {
                try await Task.sleep(for: .seconds(180))
                throw GoogleOAuthError.cancelled
            }
        } catch {
            server.stop()
            GoogleOAuthClient.cancel()
            throw error
        }
        server.stop()
        return try await GoogleOAuthClient.tokens(
            from: callback,
            redirect: redirect,
            verifier: verifier,
            state: state
        )
    }

    func cancel() {
        server.stop()
    }
}
