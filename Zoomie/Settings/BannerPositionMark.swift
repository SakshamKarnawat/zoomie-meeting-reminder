import SwiftUI

struct BannerPositionMark: View {
    let width: Double
    let height: Double

    var body: some View {
        Capsule()
            .fill(Color.accentColor)
            .frame(width: width, height: height)
    }
}
