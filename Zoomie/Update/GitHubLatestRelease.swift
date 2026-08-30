import Foundation

struct GitHubLatestRelease: Decodable {
    let publishedAt: Date
    let assets: [Asset]

    struct Asset: Decodable {
        let name: String
        let updatedAt: Date
    }

    var zipUpdatedAt: Date {
        assets.first { $0.name == "Zoomie.zip" }?.updatedAt ?? publishedAt
    }

    static func decode(from data: Data) throws -> GitHubLatestRelease {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder in
            let string = try decoder.singleValueContainer().decode(String.self)
            let fractional = ISO8601DateFormatter()
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let plain = ISO8601DateFormatter()
            plain.formatOptions = [.withInternetDateTime]
            if let date = fractional.date(from: string) ?? plain.date(from: string) {
                return date
            }
            throw DecodingError.dataCorrupted(
                .init(codingPath: decoder.codingPath, debugDescription: "Bad date \(string)")
            )
        }
        return try decoder.decode(GitHubLatestRelease.self, from: data)
    }
}
