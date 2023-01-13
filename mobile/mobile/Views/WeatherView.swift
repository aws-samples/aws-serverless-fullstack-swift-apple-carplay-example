import SwiftUI

// sheet view that displays the weather based on the user's current location
struct WeatherView: View {
    
    @Binding var showView: Bool
    
    var latitude: Double
    var longitude: Double
    var city: String
    
    @State var aqIndex: Double = 0
    @State var temperature: Double = 0
    @State var isFetching: Bool = true
    
    var body: some View {
        Text("Weather")
            .padding(20)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
        VStack(alignment: .center, spacing: 20) {
            if (isFetching) {
                LoadingView(label: "Determining the weather")
            } else {
                Text(city)
                    .font(.largeTitle)
                    .padding(.top, 75)
                Text("Temperature")
                    .font(.title)
                    .padding(.top, 50)
                Text(String(temperature))
                    .font(.title)
                Text("Air Quality Index")
                    .font(.title)
                    .padding(.top, 10)
                Text(String(aqIndex))
                    .font(.title)
            }
            Spacer()
            FormButton(label: "Dismiss", action: {showView.toggle()})
        }
        .onAppear {
            Task {
                await fetch()
            }
        }
    }
    
    // function to call the Data Service and retrieve the weather for the user's current location
    func fetch() async {
        
        isFetching = true
        
        do {
            let result = try await DataService().getWeather(latitude: latitude, longitude: longitude)
            aqIndex = result.aqIndex
            temperature = result.temperature
        } catch {
            print("Error fetching weather: \(error)")
        }

        isFetching = false
    }
}

