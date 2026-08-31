import Foundation

struct GoogleEventListResponse: Decodable {
    let items: [GoogleEventDTO]?
    let nextPageToken: String?
}
