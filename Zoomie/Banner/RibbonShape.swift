import SwiftUI

struct RibbonShape: Shape {
    var phase: Double = 0
    var notchDepth: Double = Design.ribbonNotch
    var cornerRadius: Double = Design.bannerCornerRadius
    var amplitude: Double = Design.flutterAmplitude

    var animatableData: Double {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let notch = min(notchDepth, rect.width * 0.22)
        let radius = min(cornerRadius, rect.height / 2)
        let wave = min(amplitude, rect.height * 0.12)
        let samples = 10

        func topY(at x: Double) -> Double {
            rect.minY + wave + sin(x * 0.045 + phase) * wave
        }

        func bottomY(at x: Double) -> Double {
            rect.maxY - wave + sin(x * 0.045 + phase + .pi) * wave * 0.7
        }

        var path = Path()
        let left = rect.minX
        let right = rect.maxX
        path.move(to: CGPoint(x: left, y: topY(at: left)))

        for index in 1...samples {
            let t = Double(index) / Double(samples)
            let x = left + (right - radius - left) * t
            path.addLine(to: CGPoint(x: x, y: topY(at: x)))
        }

        path.addArc(
            center: CGPoint(x: right - radius, y: topY(at: right - radius) + radius),
            radius: radius,
            startAngle: .degrees(-90),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: right, y: bottomY(at: right) - radius))
        path.addArc(
            center: CGPoint(x: right - radius, y: bottomY(at: right - radius) - radius),
            radius: radius,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )

        for index in 1...samples {
            let t = Double(index) / Double(samples)
            let x = (right - radius) - (right - radius - left) * t
            path.addLine(to: CGPoint(x: x, y: bottomY(at: x)))
        }

        path.addLine(to: CGPoint(x: left, y: bottomY(at: left)))
        path.addLine(to: CGPoint(x: left + notch, y: rect.midY + sin(phase) * wave * 0.4))
        path.closeSubpath()
        return path
    }
}
