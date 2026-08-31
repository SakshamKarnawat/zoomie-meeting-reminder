import AppKit
import Foundation

@MainActor
final class CalendarSync {
    private let catalog: EventCatalog
    private let settings: SettingsStore
    private let onRefreshed: () -> Void
    private var timer: Timer?
    private var wakeObserver: NSObjectProtocol?
    private var refreshGeneration = 0

    init(catalog: EventCatalog, settings: SettingsStore, onRefreshed: @escaping () -> Void) {
        self.catalog = catalog
        self.settings = settings
        self.onRefreshed = onRefreshed
    }

    func start() {
        registerWake()
        refreshNow()
        armTimer()
    }

    func restart() {
        timer?.invalidate()
        timer = nil
        refreshNow()
        armTimer()
    }

    func syncNow() {
        refreshNow()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        if let wakeObserver {
            NSWorkspace.shared.notificationCenter.removeObserver(wakeObserver)
            self.wakeObserver = nil
        }
    }

    private func armTimer() {
        let interval = settings.calendarSyncInterval.timeInterval
        let scheduled = Timer(timeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNow()
            }
        }
        RunLoop.main.add(scheduled, forMode: .common)
        timer = scheduled
    }

    private func refreshNow() {
        refreshGeneration += 1
        let generation = refreshGeneration
        Task { @MainActor in
            await catalog.reload()
            guard generation == refreshGeneration else { return }
            onRefreshed()
        }
    }

    private func registerWake() {
        guard wakeObserver == nil else { return }
        wakeObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didWakeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.refreshNow()
            }
        }
    }
}
