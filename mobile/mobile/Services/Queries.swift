import Amplify

// GraphQL queries to retrieve Weather and Places from the AppSync API
extension GraphQLRequest {
    
    static func getWeather(latitude: Double, longitude: Double) -> GraphQLRequest<Weather> {
        let operationName = "getWeather"
        let document = """
        query \(operationName) {
          \(operationName)(latitude: \(latitude), longitude: \(longitude)) {
            aqIndex
            temperature
            latitude
            longitude
          }
        }
        """
        
        return GraphQLRequest<Weather>(
            document: document,
            responseType: Weather.self,
            decodePath: operationName)
    }
    
    static func getPlaces(placeType: PlaceType, latitude: Double, longitude: Double, maxResults: Int) -> GraphQLRequest<[Place]> {
        let operationName = "getPlaces"
        let document = """
        query \(operationName) {
          \(operationName)(placeType: \(placeType), latitude: \(latitude), longitude: \(longitude), maxResults: \(maxResults)) {
            placeType
            name
            address
            latitude
            longitude
          }
        }
        """
        
        return GraphQLRequest<[Place]>(
            document: document,
            responseType: [Place].self,
            decodePath: operationName)
    }
}

