import Foundation

enum GoogleOAuthError: LocalizedError {
    case notConfigured
    case cancelled
    case missingCode
    case stateMismatch
    case tokenExchangeFailed(String)
    case missingRefreshToken
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            "Google sign-in is not configured. Add a Desktop OAuth client ID."
        case .cancelled:
            "Google sign-in was cancelled."
        case .missingCode:
            "Google did not return an authorization code."
        case .stateMismatch:
            "Google sign-in could not be verified. Try again."
        case .tokenExchangeFailed(let message):
            message
        case .missingRefreshToken:
            "Google did not return a refresh token. Disconnect and connect again."
        case .httpStatus(let code):
            "Google Calendar returned \(code)."
        }
    }
}
