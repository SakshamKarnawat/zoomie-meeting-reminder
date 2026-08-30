import SwiftUI

struct CatFace: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.10, height: h * 0.10)
                    .position(x: w * 0.62, y: h * 0.30)
                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.10, height: h * 0.10)
                    .position(x: w * 0.76, y: h * 0.30)
            }
        }
        .allowsHitTesting(false)
    }
}
