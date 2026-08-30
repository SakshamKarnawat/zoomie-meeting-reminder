import Foundation

enum UpcomingEventLabel {
    static func text(title: String, start: Date, now: Date) -> String {
        let minutes = Int((start.timeIntervalSince(now) / 60).rounded())
        if minutes <= 0 {
            return "\(title) · now"
        }
        if minutes < 60 {
            return "\(title) · in \(minutes) min"
        }
        let time = start.formatted(date: .omitted, time: .shortened)
        return "\(title) · \(time)"
    }
}
