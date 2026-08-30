import SwiftUI

struct CorgiSilhouette: Shape {
    var wag: Double = 0

    var animatableData: Double {
        get { wag }
        set { wag = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        let body = CGRect(x: w * 0.10, y: h * 0.42, width: w * 0.62, height: h * 0.32)
        path.addRoundedRect(in: body, cornerSize: CGSize(width: h * 0.16, height: h * 0.16))

        let head = CGRect(x: w * 0.52, y: h * 0.18, width: w * 0.40, height: h * 0.40)
        path.addEllipse(in: head)

        path.move(to: CGPoint(x: w * 0.58, y: h * 0.28))
        path.addLine(to: CGPoint(x: w * 0.52, y: h * 0.00 + wag * 3))
        path.addLine(to: CGPoint(x: w * 0.72, y: h * 0.22))
        path.closeSubpath()

        path.move(to: CGPoint(x: w * 0.74, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.90, y: h * 0.00 - wag * 3))
        path.addLine(to: CGPoint(x: w * 0.92, y: h * 0.26))
        path.closeSubpath()

        path.addEllipse(in: CGRect(x: w * 0.82, y: h * 0.36, width: w * 0.16, height: h * 0.16))

        let tailWag = wag * h * 0.16
        path.move(to: CGPoint(x: w * 0.12, y: h * 0.48))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.02, y: h * 0.28 + tailWag),
            control: CGPoint(x: w * 0.00, y: h * 0.50)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.16, y: h * 0.56),
            control: CGPoint(x: w * 0.08, y: h * 0.36)
        )

        path.addRoundedRect(
            in: CGRect(x: w * 0.18, y: h * 0.70, width: w * 0.12, height: h * 0.24),
            cornerSize: CGSize(width: 3, height: 3)
        )
        path.addRoundedRect(
            in: CGRect(x: w * 0.48, y: h * 0.70, width: w * 0.12, height: h * 0.24 + wag * 2),
            cornerSize: CGSize(width: 3, height: 3)
        )

        return path
    }
}
