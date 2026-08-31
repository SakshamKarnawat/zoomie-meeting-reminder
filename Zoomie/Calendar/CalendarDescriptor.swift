import SwiftUI

struct CalendarDescriptor: Identifiable, Hashable {
    let id: String
    let title: String
    let color: Color
    let source: CalendarSource
}
