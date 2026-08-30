import SwiftUI

struct DrawnCharacter: View {
    let choice: CharacterChoice
    let color: Color
    let wag: Double

    var body: some View {
        switch choice {
        case .corgi:
            CharacterBody(color: color, shape: CorgiSilhouette(wag: wag), face: CorgiFace())
        case .cat, .custom:
            CharacterBody(color: color, shape: CatSilhouette(wag: wag), face: CatFace())
        }
    }
}
