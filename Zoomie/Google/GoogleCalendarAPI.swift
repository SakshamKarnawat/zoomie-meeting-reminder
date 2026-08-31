import Foundation

enum GoogleCalendarAPI {
    private static let calendarListURL = URL(string: "https://www.googleapis.com/calendar/v3/users/me/calendarList")!
    private static let calendarIDAllowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~"))

    private static func rfc3339String(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: date)
    }

    static func calendarList(accessToken: String) async throws -> [GoogleCalendarListEntry] {
        var items: [GoogleCalendarListEntry] = []
        var page: String?
        repeat {
            var components = URLComponents(url: calendarListURL, resolvingAgainstBaseURL: false)!
            var query = [URLQueryItem(name: "maxResults", value: "250")]
            if let page {
                query.append(URLQueryItem(name: "pageToken", value: page))
            }
            components.queryItems = query
            let response: GoogleCalendarListResponse = try await get(components.url!, accessToken: accessToken)
            items.append(contentsOf: response.items ?? [])
            page = response.nextPageToken
        } while page != nil
        return items.filter { entry in
            !(entry.hidden ?? false)
        }
    }

    static func events(
        calendarID: String,
        accessToken: String,
        from: Date,
        to: Date
    ) async throws -> [GoogleEventDTO] {
        let encoded = calendarID.addingPercentEncoding(withAllowedCharacters: calendarIDAllowed) ?? calendarID
        let base = URL(string: "https://www.googleapis.com/calendar/v3/calendars/\(encoded)/events")!
        var items: [GoogleEventDTO] = []
        var page: String?
        repeat {
            var components = URLComponents(url: base, resolvingAgainstBaseURL: false)!
            var query = [
                URLQueryItem(name: "singleEvents", value: "true"),
                URLQueryItem(name: "orderBy", value: "startTime"),
                URLQueryItem(name: "maxResults", value: "250"),
                URLQueryItem(name: "timeMin", value: rfc3339String(from)),
                URLQueryItem(name: "timeMax", value: rfc3339String(to))
            ]
            if let page {
                query.append(URLQueryItem(name: "pageToken", value: page))
            }
            components.queryItems = query
            let response: GoogleEventListResponse = try await get(components.url!, accessToken: accessToken)
            items.append(contentsOf: response.items ?? [])
            page = response.nextPageToken
        } while page != nil
        return items.filter { !$0.isCancelled }
    }

    private static func get<T: Decodable>(_ url: URL, accessToken: String) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("Zoomie/\(AppVersion.marketing)", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode >= 400 {
            throw GoogleOAuthError.httpStatus(http.statusCode)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
