import Foundation

enum CalendarSource: String, Hashable {
    case apple
    case google

    var settingsTitle: String {
        switch self {
        case .apple: "Apple Calendar"
        case .google: "Google Calendar"
        }
    }

    func namespacedID(_ raw: String) -> String {
        switch self {
        case .apple: raw
        case .google: "google:\(raw)"
        }
    }
}
