import SwiftUI

struct CharacterBody<S: Shape, Face: View>: View {
    let color: Color
    let shape: S
    let face: Face

    var body: some View {
        ZStack {
            CharacterBackdrop(color: color)
            shape.fill(CharacterPaint.gradient(for: color))
            face
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.20), radius: 4, x: 1, y: 2)
    }
}
