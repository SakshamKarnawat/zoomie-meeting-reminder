import Foundation

final class ResumeGate: @unchecked Sendable {
    private let lock = NSLock()
    private var finished = false

    func resume(_ work: () -> Void) {
        lock.lock()
        defer { lock.unlock() }
        guard !finished else { return }
        finished = true
        work()
    }
}
