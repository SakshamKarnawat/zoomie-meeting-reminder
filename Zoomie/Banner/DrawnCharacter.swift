import SwiftUI

struct DrawnCharacter: View {
    let choice: CharacterChoice
    let wag: Double

    var body: some View {
        switch choice {
        case .corgi:
            CorgiSilhouette(wag: wag)
                .fill(Color(red: 0.86, green: 0.52, blue: 0.22))
                .overlay {
                    CorgiFace()
                }
        case .cat, .custom:
            CatSilhouette(wag: wag)
                .fill(Color(red: 0.35, green: 0.36, blue: 0.40))
                .overlay {
                    CatFace()
                }
        }
    }
}
