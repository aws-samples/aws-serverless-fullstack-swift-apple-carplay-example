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
struct Place: Codable {
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

@main
struct GetPlacesFunction: SimpleLambdaHandler {

    // function handler
    func handle(_ event: Event, context: LambdaContext) async throws -> [Place] {
    
        print("received event: \(event)")

        // get the name of the Amazon Location Place Index from the environment variable set with the CDK
        let placeIndexName = try getEnvVariable(name: "PLACE_INDEX_NAME")

        // define an Amazon Location Service client
        let client = try await LocationClient()

        // construct the place index search parameters
        let input = SearchPlaceIndexForTextInput(
            biasPosition: [event.arguments.longitude, event.arguments.latitude],
            indexName: placeIndexName,
            maxResults: event.arguments.maxResults,
            text: "\(event.arguments.placeType)"
        )

        // execute the search against the place index and return the results
        var response = [Place]()
        let result = try await client.searchPlaceIndexForText(input: input)

        result.results?.forEach { item in
            response.append(getPlace(item: item, placeType: event.arguments.placeType))
        }

        return response
    }
}

// function to retrieve the function environment variables by name
func getEnvVariable(name: String) throws -> String {
    
    guard let value = ProcessInfo.processInfo.environment[name] else {
        throw FunctionError.envError
    }
    
    return value
}

// function to flatten the Amazon Location results into the Place format
func getPlace (item: LocationClientTypes.SearchForTextResult, placeType: PlaceType) -> Place {
    
    let addressNumber = item.place!.addressNumber ?? ""
    let street = item.place!.street ?? ""
    let municipality = item.place!.municipality ?? ""
    let region = item.place!.region ?? ""
    let name = String(item.place!.label!.split(separator: ",")[0])
    let address = String("\(addressNumber) \(street), \(municipality), \(region)").trimmingCharacters(in: .whitespacesAndNewlines)
    
    return Place(
        placeType: placeType,
        name: name,
        address: address,
        latitude: item.place!.geometry!.point![0],
        longitude: item.place!.geometry!.point![1]
    )
}
