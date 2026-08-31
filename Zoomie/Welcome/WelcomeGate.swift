enum WelcomeGate {
    static func shouldShow(
        hasCompletedWelcome: Bool,
        appleAuthorized: Bool,
        googleSignedIn: Bool
    ) -> Bool {
        if hasCompletedWelcome { return false }
        if appleAuthorized || googleSignedIn { return false }
        return true
    }
}
