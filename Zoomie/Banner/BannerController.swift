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
            customImage: customImage,
            theme: settings.theme,
            font: settings.font.font
        )

        let hosting = NSHostingView(rootView: root)
        hosting.wantsLayer = true
        hosting.layer?.backgroundColor = NSColor.clear.cgColor

        let fitting = hosting.fittingSize
        let bannerWidth = max(fitting.width, Design.bannerMinWidth)
        let bannerHeight = max(fitting.height, Design.bannerMinHeight)
        hosting.frame = NSRect(x: 0, y: 0, width: bannerWidth, height: bannerHeight)

        let screenFrame = screen.frame
        let y = screenFrame.maxY - bannerHeight - Design.bannerTopMargin
        let startFrame = NSRect(
            x: screenFrame.minX - bannerWidth,
            y: y,
            width: bannerWidth,
            height: bannerHeight
        )
        let endFrame = NSRect(
            x: screenFrame.maxX,
            y: y,
            width: bannerWidth,
            height: bannerHeight
        )

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
        panel.contentView = hosting

        window = panel
        panel.setFrame(startFrame, display: true)
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Design.animationDuration
            context.timingFunction = CAMediaTimingFunction(name: .linear)
            context.allowsImplicitAnimation = true
            panel.animator().setFrame(endFrame, display: true)
        }, completionHandler: { [weak self] in
            Task { @MainActor in
                self?.finishPresentation()
            }
        })
    }

    private func finishPresentation() {
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
