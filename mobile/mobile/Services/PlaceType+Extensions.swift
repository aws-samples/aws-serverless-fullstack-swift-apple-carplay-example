extension PlaceType: Identifiable {
    
    public var id: String {
        return self.rawValue
    }
    
    public static var poiPlaces: [PlaceType] {
        return [.fuel, .coffee, .food]
    }
}
