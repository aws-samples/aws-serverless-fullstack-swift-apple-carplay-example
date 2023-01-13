import Amplify

// functions that interact with the AppSync cloud api
class DataService {
    
    // function to call AppSync API and retrieve the weather based on provided latitude and longitude
    func getWeather(latitude: Double, longitude: Double) async throws -> Weather  {
        
        do {
            let result = try await Amplify.API.query(request: .getWeather(latitude: latitude, longitude: longitude))

            switch result {
            case .success(let item):
                return item
            case .failure(let error):
                throw error
            }
            
        } catch {
            throw error
        }
    }
    
    // function to call Appsync API to retrieve points of interest for a PlaceType based on provided latitude and longitude
    // passing in a PlaceType of city will return the current city based on provided latitude and longitude
    func getPlaces(placeType: PlaceType, latitude: Double, longitude: Double, maxResults: Int) async throws-> [Place]  {

        do {
            let result = try await Amplify.API.query(request: .getPlaces(placeType: placeType, latitude: latitude, longitude: longitude, maxResults: maxResults))

            switch result {
            case .success(let item):
                return item
            case .failure(let error):
                throw error
            }
            
        } catch {
            throw error
        }
    }
    
    // function to call Appsync API to retrieve current location based on provided latitude and longitude
    func getLocation(latitude: Double, longitude: Double) async throws-> Location  {

        do {
            let result = try await Amplify.API.query(request: .getLocation(latitude: latitude, longitude: longitude))

            switch result {
            case .success(let item):
                return item
            case .failure(let error):
                throw error
            }
            
        } catch {
            throw error
        }
    }
}

