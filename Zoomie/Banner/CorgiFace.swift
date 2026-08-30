import SwiftUI

struct CorgiFace: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                eye(at: CGPoint(x: w * 0.68, y: h * 0.34), size: w * 0.13)
                eye(at: CGPoint(x: w * 0.82, y: h * 0.34), size: w * 0.13)
            }
        }
        .allowsHitTesting(false)
    }

    private func eye(at point: CGPoint, size: Double) -> some View {
        ZStack {
            Circle().fill(Color.white)
            Circle()
                .fill(Color.black)
                .frame(width: size * 0.48, height: size * 0.48)
        }
        .frame(width: size, height: size)
        .position(point)
    }
}
