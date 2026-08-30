import Foundation

struct ScheduledFire: Equatable, Identifiable {
    enum Kind: String {
        case lead
        case start
    }

    let eventIdentifier: String
    let title: String
    let startDate: Date
    let fireDate: Date
    let minutesUntilStart: Int
    let kind: Kind

    var id: String { deliveryKey }

    var deliveryKey: String {
        "\(eventIdentifier)|\(kind.rawValue)"
    }
}
