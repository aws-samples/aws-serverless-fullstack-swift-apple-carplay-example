import SwiftUI
import MapKit

// the main iOS view that displays the Map, the user's current location and action buttons
struct MapView: View {
    
    // subscribe to vehicle messages from the Cloud
    @ObservedObject var vehicleMessageService = VehicleMessageService()
    
    // subscribe to the user's current location
    @ObservedObject var locationService = LocationService()
    
    // set the initial map region
    @State private var region = MKCoordinateRegion()
    
    // state variables to control the visibility of modal sheets
    @State private var showWeatherView = false
    @State private var showPOIView = false
    @State private var showMessagesView = false
    
    var body: some View {
        ZStack {
            Map (
                coordinateRegion: $region,
                showsUserLocation: true,
                userTrackingMode: .constant(.follow)
            ).edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text(locationService.city)
                    .font(.title)
                    .padding(.bottom, 20)
                HStack {
                    MapButton(image: "cloud.fill", action: {showWeatherView.toggle()})
                        .sheet(isPresented: $showWeatherView) {
                            WeatherView(
                                showView: $showWeatherView,
                                latitude: locationService.latitude,
                                longitude: locationService.longitude,
                                city: locationService.city
                            )
                        }
                    MapButton(image: "mappin.circle", action: {showPOIView.toggle()})
                        .sheet(isPresented: $showPOIView) {
                            PlacesView(
                                showView: $showPOIView,
                                latitude: locationService.latitude,
                                longitude: locationService.longitude
                            )
                        }
                    MapButton(image: "text.bubble", action: {showMessagesView.toggle()})
                    .sheet(isPresented: $showMessagesView) {
                        MessagesView(
                            showView: $showMessagesView,
                            messages: $vehicleMessageService.messages
                        )
                    }
                }
            }
        }
        .onDisappear {
            vehicleMessageService.cancelSubscription()
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
