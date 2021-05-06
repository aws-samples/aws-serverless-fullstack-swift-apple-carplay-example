import AWSLambdaRuntime
import AsyncHTTPClient
import Foundation
import SotoSignerV4

// define struct for function event arguments
struct Event: Codable {
    let arguments: Arguments
}

enum PlaceType: String, Codable {
    case city
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

// define struct for parameters to the Amazon Location api call
// use CodingKeys to map api results to the proper case
struct APIParameters: Codable {
    let position: [Double]
    let biasPosition: [Double]
    let text: String
    let maxResults: Int
    enum CodingKeys: String, CodingKey {
        case position = "Position"
        case biasPosition = "BiasPosition"
        case text = "Text"
        case maxResults = "MaxResults"
    }
}

// define struct for the output of the Amazon Location api call
// use CodingKeys to map api results to the proper case
struct APIOutput: Codable {
    let results: [ResultItem]
    enum CodingKeys: String, CodingKey {
        case results = "Results"
    }
}

struct ResultItem: Codable {
    let place: Place
    enum CodingKeys: String, CodingKey {
        case place = "Place"
    }
}

struct Place: Codable {
    let label: String
    let geometry: Geometry
    let addressNumber: String?
    let street: String?
    let municipality: String?
    let region: String?
    enum CodingKeys: String, CodingKey {
        case label = "Label"
        case geometry = "Geometry"
        case addressNumber = "AddressNumber"
        case street = "Street"
        case municipality = "Municipality"
        case region = "Region"
    }
}

struct Geometry: Codable {
    let point: [Double]
    enum CodingKeys: String, CodingKey {
        case point = "Point"
    }
}

// define struct for the output of the lambda function
struct Output: Codable {
    let placeType: PlaceType
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
}

// define error for an error to the Amazon Location api call
enum APIError: Error {
    case apiError
}

// create an http client to use in the Amazon Location api call
// use defer to close the connection when the function completes
let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)

defer {
    try? httpClient.syncShutdown()
}

Lambda.run { (context, event: Event, callback: @escaping (Result<[Output], Error>) -> Void) in
    
    do {

        //pull in the function environment variables for the api endpoint and the AWS credentials
        var apiEndpoint = try getEnvVariable(name: "API_ENDPOINT")
        let accessKeyId = try getEnvVariable(name: "AWS_ACCESS_KEY_ID")
        let secretAccessKey = try getEnvVariable(name: "AWS_SECRET_ACCESS_KEY")
        let sessionToken = try getEnvVariable(name: "AWS_SESSION_TOKEN")
        let region = try getEnvVariable(name: "AWS_DEFAULT_REGION")
        
        // objects to encode and decode json for api calls
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        // determine specific Amazon Location endpoint based on the requested PlaceType
        if event.arguments.placeType == PlaceType.city {
            apiEndpoint += "/position"
        } else {
            apiEndpoint += "/text"
        }
        
        // create the api URL, headers, and paramaters
        // then use SotoSignerV4 to sign the request
        let url = URL(string: apiEndpoint)
        
        var headers = HTTPHeaders()
        headers.add(name: "Content-Type", value: "application/json")
        
        let parameters = APIParameters(
            position: [event.arguments.longitude, event.arguments.latitude],
            biasPosition: [event.arguments.longitude, event.arguments.latitude],
            text: "\(event.arguments.placeType)",
            maxResults: event.arguments.maxResults
        )

        let postData = try encoder.encode(parameters)
        
        let credentials = StaticCredential(
            accessKeyId: accessKeyId,
            secretAccessKey: secretAccessKey,
            sessionToken: sessionToken
        )
        
        let signer = AWSSigner(credentials: credentials, name: "geo", region: region)
        
        let processedURL = signer.processURL(url: url!)
        
        let signedHeaders = signer.signHeaders(
            url: processedURL!,
            method: .POST,
            headers: headers,
            body: .string(String(data: postData, encoding: String.Encoding.utf8)!)
        )
        
        // construct the signed request
        let request = try HTTPClient.Request(
            url: processedURL!,
            method: .POST,
            headers: signedHeaders,
            body: .string(String(data: postData, encoding: String.Encoding.utf8)!)
        )
        
        //execute the api request and determine the result status
        let response = try httpClient.execute(request: request).wait()

        if (response.status == HTTPResponseStatus.ok) {

            // decode the api request output
            let jsonResponse = try decoder.decode(APIOutput.self, from: response.body!)
            
            // map the json results into the Output format
            let items = jsonResponse.results.map { item -> Output in
                return getOutputItem(item: item, placeType: event.arguments.placeType)
            }

            // return the results of the function
            callback(.success(items))
        } else {
            print(String(buffer:response.body!))
            callback(.failure(APIError.apiError))
        }

    } catch let err {
        print(err)
        callback(.failure(err))
    }
}

// function to retrieve the function environment variables by name
func getEnvVariable(name: String) throws -> String {
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    throw APIError.apiError
}

// function to convert the Amazon Location results item to a common Output format
func getOutputItem (item: ResultItem, placeType: PlaceType) -> Output {
    
    let addressNumber: String = item.place.addressNumber ?? ""
    let street: String = item.place.street ?? ""
    let municipality: String = item.place.municipality ?? ""
    let region: String = item.place.region ?? ""
    var name: String = String(item.place.label.split(separator: ",")[0])
    var address:String = String("\(addressNumber) \(street), \(municipality), \(region)").trimmingCharacters(in: .whitespacesAndNewlines)
    
    if (placeType == PlaceType.city) {
        name = municipality
        address = ""
    }
    
    return Output(
        placeType: placeType,
        name: name,
        address: address,
        latitude: item.place.geometry.point[0],
        longitude: item.place.geometry.point[1]
    )
}


