import SwiftUI

// activity indicator with a label to display while an api call is waiting for results
struct LoadingView: View {
    
    var label = "Loading..."
    var fontSize: CGFloat = 24
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text(label)
                .padding(.top, 75)
                .font(Font.system(size:fontSize))
            ProgressView()
        }
    }
}

