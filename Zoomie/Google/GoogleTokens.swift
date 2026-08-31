import Foundation

struct GoogleTokens: Codable, Equatable {
    var accessToken: String
    var refreshToken: String
    var expiry: Date
    var email: String?
    var tokenType: String

    var isExpired: Bool {
        expiry.timeIntervalSinceNow < 60
    }
}
