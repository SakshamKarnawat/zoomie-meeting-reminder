import SwiftUI

struct CatSilhouette: Shape {
    var wag: Double = 0

    var animatableData: Double {
        get { wag }
        set { wag = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()

        let body = CGRect(x: w * 0.18, y: h * 0.38, width: w * 0.58, height: h * 0.42)
        path.addEllipse(in: body)

        let head = CGRect(x: w * 0.48, y: h * 0.12, width: w * 0.42, height: h * 0.42)
        path.addEllipse(in: head)

        path.move(to: CGPoint(x: w * 0.54, y: h * 0.22))
        path.addLine(to: CGPoint(x: w * 0.60, y: h * 0.02 + wag * 2))
        path.addLine(to: CGPoint(x: w * 0.70, y: h * 0.20))
        path.closeSubpath()

        path.move(to: CGPoint(x: w * 0.72, y: h * 0.20))
        path.addLine(to: CGPoint(x: w * 0.84, y: h * 0.00 - wag * 2))
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.22))
        path.closeSubpath()

        let tailWag = wag * w * 0.12
        path.move(to: CGPoint(x: w * 0.20, y: h * 0.52))
        path.addQuadCurve(
            to: CGPoint(x: w * 0.02, y: h * 0.22 + tailWag),
            control: CGPoint(x: w * 0.00, y: h * 0.48)
        )
        path.addQuadCurve(
            to: CGPoint(x: w * 0.22, y: h * 0.62),
            control: CGPoint(x: w * 0.06, y: h * 0.40)
        )

        path.addEllipse(in: CGRect(x: w * 0.22, y: h * 0.74, width: w * 0.12, height: h * 0.18))
        path.addEllipse(in: CGRect(x: w * 0.40, y: h * 0.76, width: w * 0.12, height: h * 0.18))

        return path
    }
}
