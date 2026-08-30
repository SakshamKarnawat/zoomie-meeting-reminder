import Testing
@testable import Zoomie

@MainActor
struct CalendarServiceReloadTests {
    @Test func reloadBumpsSnapshotOnce() {
        let service = CalendarService()
        #expect(service.snapshotID == 0)
        service.reload()
        #expect(service.snapshotID == 1)
        service.reload()
        #expect(service.snapshotID == 2)
    }
}
