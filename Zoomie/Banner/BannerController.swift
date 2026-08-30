import SwiftUI

@MainActor
final class BannerController {
    private struct PendingShow {
        let message: String
        let settings: SettingsStore
        let customImage: NSImage?
        let completion: () -> Void
    }

    private var window: NSWindow?
    private var isShowing = false
    private var onFinished: (() -> Void)?
    private var pending: PendingShow?
    private let animator = BannerAnimator()

    var isPresenting: Bool { isShowing }

    func preview(
        message: String,
        settings: SettingsStore,
        customImage: NSImage?
    ) {
        guard !isShowing else { return }
        show(message: message, settings: settings, customImage: customImage, completion: {})
    }

    func show(
        message: String,
        settings: SettingsStore,
        customImage: NSImage?,
        completion: @escaping () -> Void
    ) {
        if isShowing {
            pending = PendingShow(
                message: message,
                settings: settings,
                customImage: customImage,
                completion: completion
            )
            return
        }

        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            completion()
            return
        }

        isShowing = true
        onFinished = completion
        playLaunchSound()

        let root = BannerView(
            message: message,
            character: settings.character,
            characterColor: settings.characterColor,
            customImage: customImage,
            theme: settings.theme,
            font: settings.font.font
        )

        let host = NSHostingController(rootView: root)
        host.view.wantsLayer = true
        host.view.layer?.backgroundColor = NSColor.clear.cgColor
        var fitting = host.sizeThatFits(in: NSSize(width: 4000, height: 400))
        if fitting.width < 10 || fitting.height < 10 {
            fitting = host.view.fittingSize
        }
        let bannerWidth = max(fitting.width, Design.bannerMinWidth)
        let bannerHeight = max(fitting.height, Design.bannerMinHeight)
        host.view.frame = NSRect(x: 0, y: 0, width: bannerWidth, height: bannerHeight)

        let screenFrame = screen.visibleFrame
        let y = BannerPlacement.originY(
            visibleFrame: screenFrame,
            bannerHeight: bannerHeight,
            fromTop: settings.resolvedFromTop
        )
        let startX = BannerPlacement.startX(visibleFrame: screenFrame, bannerWidth: bannerWidth)
        let endX = BannerPlacement.endX(visibleFrame: screenFrame)
        let distance = endX - startX
        let duration = BannerMotion.duration(distance: distance)

        let startFrame = NSRect(x: startX, y: y, width: bannerWidth, height: bannerHeight)

        let panel = NSPanel(
            contentRect: startFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.ignoresMouseEvents = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isReleasedWhenClosed = false
        panel.animationBehavior = .none
        panel.contentViewController = host

        window = panel
        panel.setFrame(startFrame, display: true)
        panel.orderFrontRegardless()

        animator.start(
            window: panel,
            fromX: startX,
            toX: endX,
            y: y,
            duration: duration
        ) { [weak self] in
            self?.finishPresentation()
        }
    }

    private func finishPresentation() {
        animator.stop()
        window?.orderOut(nil)
        window = nil
        isShowing = false
        let finished = onFinished
        onFinished = nil
        finished?()

        if let pending {
            self.pending = nil
            show(
                message: pending.message,
                settings: pending.settings,
                customImage: pending.customImage,
                completion: pending.completion
            )
        }
    }

    private func playLaunchSound() {
        if let glass = NSSound(named: "Glass") {
            glass.play()
        } else if let ping = NSSound(named: "Ping") {
            ping.play()
        } else {
            NSSound.beep()
        }
    }
}
