import Foundation

enum GoogleOAuthClient {
    private static let authURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
    private static let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
    private static let revokeURL = URL(string: "https://oauth2.googleapis.com/revoke")!
    private static let lock = NSLock()
    nonisolated(unsafe) private static var activeServer: GoogleLoopbackServer?

    static func cancel() {
        lock.lock()
        let server = activeServer
        activeServer = nil
        lock.unlock()
        server?.stop()
    }

    static func begin() async throws -> GoogleOAuthPending {
        guard GoogleClientConfig.isConfigured else { throw GoogleOAuthError.notConfigured }

        let server = GoogleLoopbackServer()
        setActive(server)

        let port: UInt16
        do {
            port = try await firstResult {
                try await server.start()
            } timeout: {
                try await Task.sleep(for: .seconds(10))
                throw GoogleOAuthError.cancelled
            }
        } catch {
            server.stop()
            setActive(nil)
            throw error
        }

        let redirect = "http://127.0.0.1:\(port)"
        let verifier = GoogleOAuthPKCE.makeVerifier()
        let state = GoogleOAuthPKCE.makeState()
        let auth = authorizationURL(
            redirect: redirect,
            state: state,
            challenge: GoogleOAuthPKCE.challenge(for: verifier)
        )
        return GoogleOAuthPending(
            authorizationURL: auth,
            server: server,
            redirect: redirect,
            verifier: verifier,
            state: state
        )
    }

    static func tokens(
        from callback: URL,
        redirect: String,
        verifier: String,
        state: String
    ) async throws -> GoogleTokens {
        setActive(nil)
        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let values = Dictionary(uniqueKeysWithValues: items.compactMap { item in
            item.value.map { (item.name, $0) }
        })
        if let error = values["error"] {
            let detail = values["error_description"] ?? error
            throw GoogleOAuthError.googleDenied(detail.replacingOccurrences(of: "+", with: " "))
        }
        guard values["state"] == state else { throw GoogleOAuthError.stateMismatch }
        guard let code = values["code"] else { throw GoogleOAuthError.missingCode }

        var tokens = try await exchange(
            code: code,
            redirect: redirect,
            verifier: verifier
        )
        tokens.email = try await fetchEmail(accessToken: tokens.accessToken)
        return tokens
    }

    static func refresh(_ tokens: GoogleTokens) async throws -> GoogleTokens {
        var fields = [
            "client_id": GoogleClientConfig.clientID,
            "grant_type": "refresh_token",
            "refresh_token": tokens.refreshToken
        ]
        if !GoogleClientConfig.clientSecret.isEmpty {
            fields["client_secret"] = GoogleClientConfig.clientSecret
        }
        let response = try await post(tokenURL, body: urlEncoded(fields))
        var next = try tokensFromResponse(response, fallbackRefresh: tokens.refreshToken)
        next.email = tokens.email ?? next.email
        if next.email == nil {
            next.email = try await fetchEmail(accessToken: next.accessToken)
        }
        return next
    }

    static func revoke(_ tokens: GoogleTokens) async {
        var request = URLRequest(url: revokeURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Data("token=\(tokens.refreshToken.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? tokens.refreshToken)".utf8)
        _ = try? await URLSession.shared.data(for: request)
    }

    static func authorizationURL(redirect: String, state: String, challenge: String) -> URL {
        let fields = [
            "client_id": GoogleClientConfig.clientID,
            "redirect_uri": redirect,
            "response_type": "code",
            "scope": GoogleClientConfig.scope,
            "access_type": "offline",
            "state": state,
            "code_challenge": challenge,
            "code_challenge_method": "S256"
        ]
        let query = urlEncodedString(fields)
        return URL(string: "\(authURL.absoluteString)?\(query)")!
    }

    private static func exchange(code: String, redirect: String, verifier: String) async throws -> GoogleTokens {
        var fields = [
            "client_id": GoogleClientConfig.clientID,
            "code": code,
            "code_verifier": verifier,
            "grant_type": "authorization_code",
            "redirect_uri": redirect
        ]
        if !GoogleClientConfig.clientSecret.isEmpty {
            fields["client_secret"] = GoogleClientConfig.clientSecret
        }
        let response = try await post(tokenURL, body: urlEncoded(fields))
        return try tokensFromResponse(response, fallbackRefresh: nil)
    }

    private static func tokensFromResponse(
        _ response: GoogleTokenResponse,
        fallbackRefresh: String?
    ) throws -> GoogleTokens {
        if let error = response.error {
            let detail = response.errorDescription ?? error
            if detail.localizedCaseInsensitiveContains("client_secret") {
                throw GoogleOAuthError.tokenExchangeFailed(
                    "This build has no Desktop client secret. GitHub releases stamp it from the ZOOMIE_GOOGLE_CLIENT_SECRET Actions secret. For a local build, paste it in Settings, then Connect again."
                )
            }
            throw GoogleOAuthError.tokenExchangeFailed(detail)
        }
        guard let accessToken = response.accessToken, !accessToken.isEmpty else {
            throw GoogleOAuthError.tokenExchangeFailed("Google did not return an access token.")
        }
        guard let refresh = response.refreshToken ?? fallbackRefresh, !refresh.isEmpty else {
            throw GoogleOAuthError.missingRefreshToken
        }
        let lifetime = TimeInterval(response.expiresIn ?? 3600)
        return GoogleTokens(
            accessToken: accessToken,
            refreshToken: refresh,
            expiry: Date().addingTimeInterval(lifetime),
            email: nil,
            tokenType: response.tokenType ?? "Bearer"
        )
    }

    private static func fetchEmail(accessToken: String) async throws -> String? {
        var request = URLRequest(url: URL(string: "https://www.googleapis.com/oauth2/v2/userinfo")!)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        let (data, _) = try await URLSession.shared.data(for: request)
        return try? JSONDecoder().decode(GoogleUserProfile.self, from: data).email
    }

    private static func post(_ url: URL, body: Data) async throws -> GoogleTokenResponse {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(GoogleTokenResponse.self, from: data)
    }

    /// Google’s samples encode `:` but leave `/` (`http%3A//127.0.0.1%3A9004`).
    static let formAllowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~/"))

    private static func urlEncoded(_ fields: [String: String]) -> Data {
        Data(urlEncodedString(fields).utf8)
    }

    private static func urlEncodedString(_ fields: [String: String]) -> String {
        fields.map { key, value in
            let encoded = value.addingPercentEncoding(withAllowedCharacters: formAllowed) ?? value
            return "\(key)=\(encoded)"
        }
        .joined(separator: "&")
    }

    private static func setActive(_ server: GoogleLoopbackServer?) {
        lock.lock()
        activeServer = server
        lock.unlock()
    }

    static func firstResult<T: Sendable>(
        _ work: @escaping @Sendable () async throws -> T,
        timeout: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await work() }
            group.addTask { try await timeout() }
            let first = try await group.next()!
            group.cancelAll()
            return first
        }
    }
}
