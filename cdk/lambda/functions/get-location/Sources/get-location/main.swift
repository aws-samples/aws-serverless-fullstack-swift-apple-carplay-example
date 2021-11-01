import AWSLambdaRuntime
import Foundation
import AWSLocation

// define struct for function event arguments
struct Event: Codable {
    let arguments: Arguments
}

struct Arguments: Codable {
    let latitude: Double
    let longitude: Double
}

// define struct for the output of the lambda function
struct Output: Codable {
    let name: String
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

Lambda.run { (context, event: Event, callback: @escaping (Result<Output, Error>) -> Void) in
    
    // construct our place index search parameters
    let input = SearchPlaceIndexForPositionInput(
        indexName: placeIndexName,
        maxResults: 1,
        position: [event.arguments.longitude, event.arguments.latitude]
    )

    // execute the search against the place index and return the results
    client.searchPlaceIndexForPosition(input: input) { (result) in
        switch(result) {
        case .success(let output):
            let item = getOutputItem(item: output.results![0])
            callback(.success(item))
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
func getOutputItem (item: LocationClientTypes.SearchForPositionResult) -> Output {
    
    let municipality = item.place!.municipality ?? ""
    let region = item.place!.region ?? ""
    let name = String("\(municipality), \(region)").trimmingCharacters(in: .whitespacesAndNewlines)

    return Output(
        name:  name,
        latitude: item.place!.geometry!.point![0],
        longitude: item.place!.geometry!.point![1]
    )
}

