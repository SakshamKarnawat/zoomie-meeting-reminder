import AppKit
import Foundation

enum GoogleOAuthClient {
    private static let authURL = URL(string: "https://accounts.google.com/o/oauth2/v2/auth")!
    private static let tokenURL = URL(string: "https://oauth2.googleapis.com/token")!
    private static let revokeURL = URL(string: "https://oauth2.googleapis.com/revoke")!

    static func signIn() async throws -> GoogleTokens {
        guard GoogleClientConfig.isConfigured else { throw GoogleOAuthError.notConfigured }

        let server = GoogleLoopbackServer()
        let port = try await server.start()
        let redirect = "http://127.0.0.1:\(port)"
        let verifier = GoogleOAuthPKCE.makeVerifier()
        let state = GoogleOAuthPKCE.makeState()
        let auth = authorizationURL(
            redirect: redirect,
            state: state,
            challenge: GoogleOAuthPKCE.challenge(for: verifier)
        )
        NSWorkspace.shared.open(auth)

        let callback: URL
        do {
            callback = try await withThrowingTaskGroup(of: URL.self) { group in
                group.addTask { try await server.waitForRedirect() }
                group.addTask {
                    try await Task.sleep(for: .seconds(180))
                    throw GoogleOAuthError.cancelled
                }
                let first = try await group.next()!
                group.cancelAll()
                return first
            }
        } catch {
            server.stop()
            throw error
        }
        server.stop()

        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        let values = Dictionary(uniqueKeysWithValues: items.compactMap { item in
            item.value.map { (item.name, $0) }
        })
        if values["error"] != nil { throw GoogleOAuthError.cancelled }
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
        let body = urlEncoded([
            "client_id": GoogleClientConfig.clientID,
            "grant_type": "refresh_token",
            "refresh_token": tokens.refreshToken
        ])
        let response = try await post(tokenURL, body: body)
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

    private static func authorizationURL(redirect: String, state: String, challenge: String) -> URL {
        var components = URLComponents(url: authURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: GoogleClientConfig.clientID),
            URLQueryItem(name: "redirect_uri", value: redirect),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: GoogleClientConfig.scope),
            URLQueryItem(name: "access_type", value: "offline"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        return components.url!
    }

    private static func exchange(code: String, redirect: String, verifier: String) async throws -> GoogleTokens {
        let body = urlEncoded([
            "client_id": GoogleClientConfig.clientID,
            "code": code,
            "code_verifier": verifier,
            "grant_type": "authorization_code",
            "redirect_uri": redirect
        ])
        let response = try await post(tokenURL, body: body)
        return try tokensFromResponse(response, fallbackRefresh: nil)
    }

    private static func tokensFromResponse(
        _ response: GoogleTokenResponse,
        fallbackRefresh: String?
    ) throws -> GoogleTokens {
        if let error = response.error {
            throw GoogleOAuthError.tokenExchangeFailed(response.errorDescription ?? error)
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

    private static let formAllowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))

    private static func urlEncoded(_ fields: [String: String]) -> Data {
        let joined = fields.map { key, value in
            let encoded = value.addingPercentEncoding(withAllowedCharacters: formAllowed) ?? value
            return "\(key)=\(encoded)"
        }
        .joined(separator: "&")
        return Data(joined.utf8)
    }
}
