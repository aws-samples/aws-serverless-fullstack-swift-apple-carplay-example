import SwiftUI

// button object for the modal sheets
struct FormButton: View {

    var label: String
    var action: () -> Void

    var body: some View {
            Button(action: action) {
                Text(label)
                    .font(.custom("button", fixedSize: 16))
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .padding(2)
            }
    }
}

