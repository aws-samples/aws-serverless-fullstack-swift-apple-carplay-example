import SwiftUI

// sheet view that displays cloud subscription messages received from the AppSync API
struct MessagesView: View {
    
    @Binding var showView: Bool
    @Binding var messages: [VehicleMessage]
    
    var body: some View {
        Text("Messages")
            .padding(20)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .center, spacing: 20) {
            if messages.isEmpty {
                Text("You have no messages")
                    .padding(.top, 100)
                    .font(Font.system(size:20))
            } else {
                List {
                    ForEach (messages) { item in
                        Text(item.message)
                    }
                }
            }
            Spacer()
            HStack {
                FormButton(label: "Dismiss", action: {showView.toggle()})
                if !messages.isEmpty  {
                    FormButton(label: "Clear", action: {messages.removeAll()})
                }
            }
        }
    }
}
