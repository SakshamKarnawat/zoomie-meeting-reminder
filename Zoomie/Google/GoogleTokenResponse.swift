import Foundation

struct GoogleTokenResponse: Decodable {
    let accessToken: String?
    let expiresIn: Int?
    let refreshToken: String?
    let tokenType: String?
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case error
        case errorDescription = "error_description"
    }
}
