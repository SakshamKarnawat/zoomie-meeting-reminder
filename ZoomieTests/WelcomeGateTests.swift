import Testing
@testable import Zoomie

struct WelcomeGateTests {
    @Test func firstLaunchWithNoCalendarsShowsWelcome() {
        #expect(
            WelcomeGate.shouldShow(
                hasCompletedWelcome: false,
                appleAuthorized: false,
                googleSignedIn: false
            )
        )
    }

    @Test func completedWelcomeDoesNotShowAgain() {
        #expect(
            !WelcomeGate.shouldShow(
                hasCompletedWelcome: true,
                appleAuthorized: false,
                googleSignedIn: false
            )
        )
    }

    @Test func existingAppleAccessSkipsWelcome() {
        #expect(
            !WelcomeGate.shouldShow(
                hasCompletedWelcome: false,
                appleAuthorized: true,
                googleSignedIn: false
            )
        )
    }

    @Test func existingGoogleSessionSkipsWelcome() {
        #expect(
            !WelcomeGate.shouldShow(
                hasCompletedWelcome: false,
                appleAuthorized: false,
                googleSignedIn: true
            )
        )
    }
}
