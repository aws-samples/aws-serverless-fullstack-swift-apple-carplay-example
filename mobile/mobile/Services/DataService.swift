import Amplify

// functions that interact with the AppSync cloud api
class DataService {
    
    // function to call AppSync API and retrieve the weather based on provided latitude and longitude
    func getWeather(latitude: Double, longitude: Double, completion: @escaping (Result<Weather, Error>) -> Void)  {
        
        Amplify.API.query(request: .getWeather(latitude: latitude, longitude: longitude)) { event in
            switch event {
            case .success(let result):
                switch result {
                    case .success(let item):
                        completion(.success(item))
                    case .failure(let error):
                        completion(.failure(error))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // function to call Appsync API to retrieve points of interest for a PlaceType based on provided latitude and longitude
    // passing in a PlaceType of city will return the current city based on provided latitude and longitude
    func getPlaces(placeType: PlaceType, latitude: Double, longitude: Double, maxResults: Int, completion: @escaping (Result<[Place], Error>) -> Void)  {
        
        Amplify.API.query(request: .getPlaces(placeType: placeType, latitude: latitude, longitude: longitude, maxResults: maxResults)) { event in
            switch event {
            case .success(let result):
                switch result {
                    case .success(let item):
                        completion(.success(item))
                    case .failure(let error):
                        completion(.failure(error))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // function to call Appsync API to retrieve current location based on provided latitude and longitude
    func getLocation(latitude: Double, longitude: Double, completion: @escaping (Result<Location, Error>) -> Void)  {
        
        Amplify.API.query(request: .getLocation(latitude: latitude, longitude: longitude)) { event in
            switch event {
            case .success(let result):
                switch result {
                    case .success(let item):
                        completion(.success(item))
                    case .failure(let error):
                        completion(.failure(error))
                    }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

