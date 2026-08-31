import Foundation

struct GoogleEventAttendee: Decodable {
    let email: String?
    let selfAttendee: Bool?
    let responseStatus: String?

    enum CodingKeys: String, CodingKey {
        case email
        case selfAttendee = "self"
        case responseStatus
    }

    var isSelfDeclined: Bool {
        (selfAttendee ?? false) && responseStatus == "declined"
    }
}
