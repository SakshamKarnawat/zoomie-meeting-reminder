import SwiftUI

struct CorgiFace: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.09, height: h * 0.09)
                    .position(x: w * 0.68, y: h * 0.34)
                Circle()
                    .fill(Color.white)
                    .frame(width: w * 0.09, height: h * 0.09)
                    .position(x: w * 0.80, y: h * 0.34)
            }
        }
        .allowsHitTesting(false)
    }
}
