import AWSLambdaRuntime
import Foundation
import AWSLocation

// define struct for function event arguments
struct Event: Codable {
    let arguments: Arguments
}

enum PlaceType: String, Codable {
    case coffee
    case fuel
    case food
}

struct Arguments: Codable {
    let placeType: PlaceType
    let latitude: Double
    let longitude: Double
    let maxResults: Int
}

// define struct for the output of the lambda function
struct Output: Codable {
    let placeType: PlaceType
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}

// define function error types
enum FunctionError: Error {
    case envError
}

// get the name of the Amazon Location Place Index from the environment variable set with the CDK
let placeIndexName = try getEnvVariable(name: "PLACE_INDEX_NAME")

// define an Amazon Location Service client
let client = try LocationClient()

Lambda.run { (context, event: Event, callback: @escaping (Result<[Output], Error>) -> Void) in
    
    var response = [Output]()

    // construct our place index search parameters
    let input = SearchPlaceIndexForTextInput(
        biasPosition: [event.arguments.longitude, event.arguments.latitude],
        indexName: placeIndexName,
        maxResults: event.arguments.maxResults,
        text: "\(event.arguments.placeType)"
    )

    // execute the search against the place index and return the results
    client.searchPlaceIndexForText(input: input) { (result) in
        switch(result) {
        case .success(let output):
            output.results?.forEach { item in
                response.append(getOutputItem(item: item, placeType: event.arguments.placeType))
            }
            callback(.success(response))
        case .failure(let error):
            callback(.failure(error))
        }
    }
}

// function to retrieve the function environment variables by name
func getEnvVariable(name: String) throws -> String {
    
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    
    throw FunctionError.envError
}

// function to flatten the Amazon Location results into the Output format
func getOutputItem (item: LocationClientTypes.SearchForTextResult, placeType: PlaceType) -> Output {
    
    let addressNumber = item.place!.addressNumber ?? ""
    let street = item.place!.street ?? ""
    let municipality = item.place!.municipality ?? ""
    let region = item.place!.region ?? ""
    let name = String(item.place!.label!.split(separator: ",")[0])
    let address = String("\(addressNumber) \(street), \(municipality), \(region)").trimmingCharacters(in: .whitespacesAndNewlines)
    
    return Output(
        placeType: placeType,
        name: name,
        address: address,
        latitude: item.place!.geometry!.point![0],
        longitude: item.place!.geometry!.point![1]
    )
}


