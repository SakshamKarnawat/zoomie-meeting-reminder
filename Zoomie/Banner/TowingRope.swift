import SwiftUI

struct TowingRope: View {
    let color: Color

    var body: some View {
        Capsule()
            .fill(color)
            .frame(width: Design.ropeLength, height: Design.ropeThickness)
            .padding(.horizontal, -Design.ropeOverlap)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }
}
