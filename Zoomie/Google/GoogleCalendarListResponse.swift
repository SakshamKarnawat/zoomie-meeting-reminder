import Foundation

struct GoogleCalendarListResponse: Decodable {
    let items: [GoogleCalendarListEntry]?
    let nextPageToken: String?
}
