import SwiftUI

// sheet view that displays local points of interest based on the user's current location
struct PlacesView: View {
    
    struct PlaceItem: Identifiable {
        let id = UUID()
        let name: String
        let address: String
    }
    
    @Binding var showView: Bool
    var latitude: Double
    var longitude: Double
    
    @State private var places: [PlaceItem] = []
    @State private var selectedPlaceType: PlaceType = PlaceType.fuel
    @State private var isFetching = true
    
    var body: some View {
        Text("Places")
            .padding(20)
            .font(.title)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        VStack(alignment: .center, spacing: 20) {
            HStack (spacing: 20){
                ForEach(PlaceType.poiPlaces) { type in
                    let label = type.rawValue.capitalized
                    
                    if selectedPlaceType == type {
                        PlaceTypeText(label: label)
                    } else {
                        Button(label, action: {
                            Task {
                                await fetch(placeType: type)
                            }
                        })
                    }
                }
            }
            if isFetching {
                LoadingView(label: "Searching nearby places", fontSize: 18)
            } else {
                List {
                    ForEach (places) { item in
                        VStack(alignment: .leading) {
                            Text(item.name)
                            Text(item.address)
                                .font(Font.system(size:14))
                        }
                    }
                }
            }
            Spacer()
            FormButton(label: "Dismiss", action: {showView.toggle()}
            ).onAppear {
                Task {
                    await fetch(placeType: selectedPlaceType)
                }
            }
        }
    }
        
    // view to display the selected place type
    struct PlaceTypeText: View {

        var label: String

        var body: some View {
            Text(label)
               .font(.custom("button", fixedSize: 16))
               .padding(10)
               .background(Color.blue)
               .cornerRadius(10)
               .foregroundColor(.white)
        }
    }
        
    // function to call the Data Service and retrieve the closest places based on the requested PlaceType and the user's location
    func fetch(placeType: PlaceType) async {
        
        self.selectedPlaceType = placeType
        
        places.removeAll()
        
        isFetching = true
        
        do {
            let result = try await DataService().getPlaces(placeType: placeType, latitude: latitude, longitude: longitude, maxResults: 5)
            for p in result {
                places.append(PlaceItem(name: p.name, address: p.address))
            }
        } catch {
            print("Error fetching places: \(error)")
        }
        
        isFetching = false
    }
}


