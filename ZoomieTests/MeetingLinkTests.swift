import Foundation
import Testing
@testable import Zoomie

struct MeetingLinkTests {
    @Test func prefersEventURL() {
        let url = URL(string: "https://zoom.us/j/1")!
        #expect(MeetingLink.url(eventURL: url, notes: "https://example.com", location: nil) == url)
    }

    @Test func findsKnownHostInNotes() {
        let found = MeetingLink.url(
            eventURL: nil,
            notes: "Join here https://meet.google.com/abc-defg-hij thanks",
            location: "Office"
        )
        #expect(found?.host == "meet.google.com")
    }

    @Test func ignoresNonHTTPEventURL() {
        #expect(
            MeetingLink.url(
                eventURL: URL(string: "x-apple-eventkit://event"),
                notes: nil,
                location: nil
            ) == nil
        )
    }
}
