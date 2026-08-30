import AppKit
import QuartzCore

@MainActor
final class BannerAnimator {
    private var timer: Timer?
    private var window: NSWindow?
    private var startX: Double = 0
    private var endX: Double = 0
    private var y: Double = 0
    private var duration: TimeInterval = 1
    private var startTime: TimeInterval = 0
    private var onFinished: (() -> Void)?

    func start(
        window: NSWindow,
        fromX: Double,
        toX: Double,
        y: Double,
        duration: TimeInterval,
        onFinished: @escaping () -> Void
    ) {
        stop()
        self.window = window
        startX = fromX
        endX = toX
        self.y = y
        self.duration = max(duration, 0.25)
        self.onFinished = onFinished
        startTime = CACurrentMediaTime()
        window.setFrameOrigin(NSPoint(x: fromX, y: y))

        let timer = Timer(timeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        timer.tolerance = 0
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        tick()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        let elapsed = CACurrentMediaTime() - startTime
        let fraction = min(elapsed / duration, 1)
        let traveled = BannerMotion.progress(elapsedFraction: fraction)
        let x = startX + (endX - startX) * traveled
        window?.setFrameOrigin(NSPoint(x: x, y: y))

        if fraction >= 1 {
            stop()
            let finished = onFinished
            onFinished = nil
            finished?()
        }
    }
}
