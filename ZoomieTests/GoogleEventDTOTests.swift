import Foundation
import Testing
@testable import Zoomie

struct GoogleEventDTOTests {
    @Test func prefersHangoutLinkAndIgnoresHtmlLink() throws {
        let json = """
        {
          "id": "evt",
          "summary": "Standup",
          "hangoutLink": "https://meet.google.com/abc-defg-hij",
          "htmlLink": "https://www.google.com/calendar/event?eid=abc",
          "start": { "dateTime": "2026-09-01T10:00:00Z" }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(GoogleEventDTO.self, from: json)
        #expect(dto.eventURL?.host == "meet.google.com")
    }

    @Test func skipsHtmlLinkWhenThereIsNoMeet() throws {
        let json = """
        {
          "id": "evt",
          "summary": "Standup",
          "htmlLink": "https://www.google.com/calendar/event?eid=abc",
          "start": { "dateTime": "2026-09-01T10:00:00Z" }
        }
        """.data(using: .utf8)!
        let dto = try JSONDecoder().decode(GoogleEventDTO.self, from: json)
        #expect(dto.eventURL == nil)
    }
}
