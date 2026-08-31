import Foundation

enum EventDedupe {
    static let window: TimeInterval = 90

    static func merge(apple: [TimedEvent], google: [TimedEvent]) -> [TimedEvent] {
        var merged = apple
        for candidate in google {
            if let index = merged.firstIndex(where: { isSameMeeting($0, candidate) }) {
                if merged[index].joinURL == nil, candidate.joinURL != nil {
                    merged[index] = candidate
                }
                continue
            }
            merged.append(candidate)
        }
        return merged.sorted { $0.startDate < $1.startDate }
    }

    private static func isSameMeeting(_ lhs: TimedEvent, _ rhs: TimedEvent) -> Bool {
        lhs.title.caseInsensitiveCompare(rhs.title) == .orderedSame
            && abs(lhs.startDate.timeIntervalSince(rhs.startDate)) < window
    }
}
