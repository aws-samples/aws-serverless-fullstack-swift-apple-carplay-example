import CoreLocation
import Combine
import Amplify

// delegate to provide location data to Carplay as Carply does not support Swift based ObservedObject
// the iPhone app utilises ObservedObject bindings
protocol LocationServiceDelegate: AnyObject {
    func locationService(latitude: Double, longitude: Double, city: String)
}

// the Location service utilizes CoreLocation to monitor the movement of the user
// updates are published every 1/2 mile (800 meters)
class LocationService: NSObject, ObservableObject {
    
    weak var delegate:LocationServiceDelegate?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 800
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    // variables the LocationManager publishes top consumers
    @Published var locationStatus: CLAuthorizationStatus? {
        willSet {
            objectWillChange.send()
        }
    }

    @Published var lastLocation: CLLocation? {
        willSet {
            objectWillChange.send()
        }
    }
    
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var city = ""
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }

        switch status {
            case .notDetermined: return "notDetermined"
            case .authorizedWhenInUse: return "authorizedWhenInUse"
            case .authorizedAlways: return "authorizedAlways"
            case .restricted: return "restricted"
            case .denied: return "denied"
            default: return "unknown"
        }

    }
    
    let objectWillChange = PassthroughSubject<Void, Never>()

    private let locationManager = CLLocationManager()
    
    func stopUpdatingLocation(){
        self.locationManager.stopUpdatingLocation()
    }
}

// delegate to handle events fired by CoreLocation
extension LocationService: CLLocationManagerDelegate {

    // event received when the user's Location authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        self.locationStatus = status
    }

    // event received when the user's Location changes
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        self.lastLocation = location
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        
        Task {
            do {
                let result = try await DataService().getLocation(latitude: self.latitude, longitude: self.longitude)
                self.city = result.name
                self.delegate?.locationService(latitude: self.latitude, longitude: self.longitude, city: self.city)
            } catch {
                print("Error fetching location: \(error)")
            }
        }
    }
}




