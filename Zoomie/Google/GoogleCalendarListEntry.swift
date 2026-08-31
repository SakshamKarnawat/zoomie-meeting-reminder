import Foundation

struct GoogleCalendarListEntry: Decodable {
    let id: String
    let summary: String?
    let backgroundColor: String?
    let selected: Bool?
    let hidden: Bool?
}
