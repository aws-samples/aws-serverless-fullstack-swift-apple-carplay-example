import SwiftUI

// buttons with system images displayed on the MapView
struct MapButton: View {

    var image: String
    var action: () -> Void

    var body: some View {
            Button(action: action) {
            Image(systemName: image)
                .font(.title)
                .frame(width: 60, height: 60, alignment: .center)
                .background(Color.gray)
                .clipShape(Circle())
                .foregroundColor(.white)
            }
    }
}


