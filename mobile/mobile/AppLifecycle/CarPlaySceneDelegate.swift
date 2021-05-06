import CarPlay

class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {

    var carWindow: CPWindow?
    var interfaceController: CPInterfaceController?
    
    // services to receive location and messages
    var locationService: LocationService?
    var vehicleMessageService: VehicleMessageService?
    
    // templates for each screen type
    var mapTemplate: CPMapTemplate?
    var coffeeTemplate: CPListTemplate?
    var fuelTemplate: CPListTemplate?
    var foodTemplate: CPListTemplate?
    var weatherTemplate: CPInformationTemplate?
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        
        print("Connected to CarPlay.")
        
        self.interfaceController = interfaceController
        self.carWindow = window

        // initialize the templates that display each screen
        initTemplates()
        
        window.rootViewController = CarPlayMapView()
        interfaceController.setRootTemplate(mapTemplate!, animated: true, completion: nil)

        // initiate the services that provide data
        self.locationService = LocationService()
        self.locationService?.delegate = self
        
        self.vehicleMessageService = VehicleMessageService()
        self.vehicleMessageService?.delegate = self
    }
    
    func getMapBarButtons() -> [CPBarButton] {
        
        // buttons for Weather and Places in the app main navbar
        var buttons: [CPBarButton] = [CPBarButton]()
        
        buttons.append(CPBarButton(image: UIImage(systemName: "mappin.circle.fill")!, handler: { item in
            print("places clicked")
            self.interfaceController?.pushTemplate(self.getPlacesGridTemplate(), animated: true, completion: nil)
        }))

        buttons.append(CPBarButton(image: UIImage(systemName: "cloud.fill")!, handler: { item in
            print("weather clicked")
            self.interfaceController?.pushTemplate(self.weatherTemplate!, animated: true, completion: nil)
        }))
        
        return buttons
    }
    
    func getPlacesGridTemplate() -> CPGridTemplate {
        
        // buttons and actions displayed when user selects the Places icon in the main navbar
        var gridButtons: [CPGridButton] = [CPGridButton]()
        
        gridButtons.append(CPGridButton(titleVariants: ["Coffee"], image: UIImage(named: "poi", in: Bundle.main, compatibleWith: self.carWindow?.rootViewController?.traitCollection)!, handler: { item in
            self.interfaceController?.pushTemplate(self.coffeeTemplate!, animated: true, completion: nil)
        }))
        
        gridButtons.append(CPGridButton(titleVariants: ["Food"], image: UIImage(named: "poi", in: Bundle.main, compatibleWith: self.carWindow?.rootViewController?.traitCollection)!, handler: { item in
            self.interfaceController?.pushTemplate(self.foodTemplate!, animated: true, completion: nil)
        }))
        
        gridButtons.append(CPGridButton(titleVariants: ["Fuel"], image: UIImage(named: "poi", in: Bundle.main, compatibleWith: self.carWindow?.rootViewController?.traitCollection)!, handler: { item in
            self.interfaceController?.pushTemplate(self.fuelTemplate!, animated: true, completion: nil)
        }))
        
        return CPGridTemplate(title: "Places", gridButtons: gridButtons)
    }
    
    
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController, from window: CPWindow) {

        print("Disconnected from CarPlay.")
        
        self.interfaceController = nil
    }
    
    func initTemplates() {
        
        // initialize the templates with their title and empty data
        self.mapTemplate = CPMapTemplate()
        self.mapTemplate?.trailingNavigationBarButtons.append(contentsOf: getMapBarButtons())
        
        self.coffeeTemplate = CPListTemplate(title: "Coffee", sections: [CPListSection(items: [])])
        
        self.fuelTemplate = CPListTemplate(title: "Fuel", sections: [CPListSection(items: [])])
        
        self.foodTemplate = CPListTemplate(title: "Food", sections: [CPListSection(items: [])])
        
        self.weatherTemplate = CPInformationTemplate(title: "Weather", layout: CPInformationTemplateLayout.twoColumn, items: [], actions: [])
        
    }
    
    func getPlaces (template: CPListTemplate, latitude: Double, longitude: Double, placeType: PlaceType) {
        
        // call the Data Service to retrieve the requested PlaceTypes for the user's current location
        // and update the provided places template
        
        var listItems: [CPListItem] = [CPListItem]()
        
        DataService().getPlaces(placeType: placeType, latitude: latitude, longitude: longitude, maxResults: 3) { result in
            
            switch (result) {
            case .success(let places):

                for place in places {
                    let item = CPListItem(text: place.name, detailText: place.address)
                    
                    item.handler = { item, completion in
                        self.interfaceController?.popToRootTemplate(animated: true) {_, _ in

                            // display an alert to select this destination
                            // future functionality would be to initiate navigation directions
                            let alert = CPNavigationAlert(
                                titleVariants: [place.name],
                                subtitleVariants: [place.address],
                                image: nil,
                                primaryAction: CPAlertAction(title: "Go", style: CPAlertAction.Style.default, handler: {_ in }),
                                secondaryAction: nil,
                                duration: TimeInterval(20))
                            
                            self.mapTemplate?.present(navigationAlert: alert, animated: true)
                        }
                    }
        
                    listItems.append(item)
                }
            case .failure(let error):
                print("Error fetching places: \(error)")
            }

            template.updateSections([CPListSection(items: listItems)])
        }
    }
    
    func getWeather (template: CPInformationTemplate, latitude: Double, longitude: Double, city: String) {
        
        // call the Data Service to retrieve the weather for the user's current location and update the weatherTemplate
        DataService().getWeather(latitude: latitude, longitude: longitude) { result in
            switch (result) {
            case .success(let item):
                template.items.removeAll()
                template.items.append(CPInformationItem(title: "City", detail: city))
                template.items.append(CPInformationItem(title: "Temperature", detail: String(item.temperature)))
                template.items.append(CPInformationItem(title: "Air Quality Index", detail: String(item.aqIndex)))
            case .failure (let error):
                print("Error fetching weather: \(error)")
            }

        }
    }
}

extension CarPlaySceneDelegate: LocationServiceDelegate {
    
    // event fired from the location service every time the user's location changes by 1/2 mile
    // update template content based on the user's new location
    
    func locationService(latitude: Double, longitude: Double, city: String) {
        getWeather(template: self.weatherTemplate!, latitude: latitude, longitude: longitude, city: city)
        getPlaces(template: self.coffeeTemplate!, latitude: latitude, longitude: longitude, placeType: PlaceType.coffee)
        getPlaces(template: self.fuelTemplate!, latitude: latitude, longitude: longitude, placeType: PlaceType.fuel)
        getPlaces(template: self.foodTemplate!, latitude: latitude, longitude: longitude, placeType: PlaceType.food)
    }
}

extension CarPlaySceneDelegate: VehicleMessageServiceDelegate {
    
    // event fired when a new message is received from the vehicle message subscription
    // display the message as an Alert template
    
    func vehicleMessageService(message: String) {
        
        print("CarPlay received message from Cloud: \(message)")
        
        let okAction = CPAlertAction(title: "OK", style: CPAlertAction.Style.default, handler: {item in
            print("OK button pressed")
            self.interfaceController?.dismissTemplate(animated: true, completion: nil)
        })
        
        let actionTemplate = CPActionSheetTemplate(title: "New Message", message: message, actions: [okAction])

        self.interfaceController?.presentTemplate(actionTemplate,animated: true, completion: nil)
    }
}
