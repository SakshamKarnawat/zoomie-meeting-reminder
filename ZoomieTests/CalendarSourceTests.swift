import Foundation
import Testing
@testable import Zoomie

struct CalendarSourceTests {
    @Test func googleIDsAreNamespaced() {
        #expect(CalendarSource.google.namespacedID("primary") == "google:primary")
        #expect(CalendarSource.apple.namespacedID("home") == "home")
    }
}
