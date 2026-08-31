import Foundation

struct GoogleEventDTO: Decodable {
    let id: String?
    let status: String?
    let summary: String?
    let description: String?
    let location: String?
    let hangoutLink: String?
    let start: GoogleEventDate?
    let end: GoogleEventDate?
    let attendees: [GoogleEventAttendee]?

    var isCancelled: Bool {
        status == "cancelled"
    }

    var userDeclined: Bool {
        attendees?.contains(where: \.isSelfDeclined) ?? false
    }

    var eventURL: URL? {
        hangoutLink.flatMap(URL.init(string:))
    }
}
