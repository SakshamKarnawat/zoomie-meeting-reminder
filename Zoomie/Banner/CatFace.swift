import SwiftUI

struct CatFace: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                eye(at: CGPoint(x: w * 0.62, y: h * 0.30), size: w * 0.14)
                eye(at: CGPoint(x: w * 0.78, y: h * 0.30), size: w * 0.14)
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
