import AWSLambdaRuntime
import AsyncHTTPClient
import Foundation
import SotoSecretsManager

//structure for Lambda Event arguments
struct Event: Codable {
    let arguments: Arguments
}

struct Arguments: Codable {
    let latitude: Double
    let longitude: Double
}

//structure for the lambda function output
struct Output : Codable {
    let temperature: Double
    let aqIndex: Int
    let latitude: Double
    let longitude: Double
}

//structure for the response to the IQAir air quality api call
struct APIRepsonse: Codable {
    let status: String
    let data: DataClass
}

struct DataClass: Codable {
    let current: Current
}

struct Current: Codable {
    let weather: Weather
    let pollution: Pollution
}

struct Pollution: Codable {
    let aqius: Int
}

struct Weather: Codable {
    let tp: Double
}

// define error for an error to the Amazon Location api call
enum APIError: Error {
    case apiError
}

// instantiate the aws client and defer shutdown until the end of the function call
let awsClient = AWSClient(credentialProvider: .environment, httpClientProvider: .createNew)
defer { try? awsClient.syncShutdown() }

Lambda.run { (context, event: Event, callback: @escaping (Result<Output, Error>) -> Void) in
        
    do {
        
        //decode to parse the air quality api result
        let decoder = JSONDecoder()
        
        //get lambda function environment variables for api endpoint and secret key name
        let apiEndpoint = try getEnvVariable(name: "API_ENDPOINT")
        let apiKeySecretName = try getEnvVariable(name: "API_KEY_SECRET_NAME")
        
        // call SecretsManager to obtain the air quality api key
        let secretsManager = SecretsManager(client: awsClient)
        let secretRequest = SecretsManager.GetSecretValueRequest(secretId: apiKeySecretName)
        let secretResponse = try secretsManager.getSecretValue(secretRequest).wait()
        let apiKey = secretResponse.secretString!
        
        //construct the url for the air quality api call with the api key, latitude, and longitude
        let url = "\(apiEndpoint)?key=\(apiKey)&lat=\(event.arguments.latitude)&lon=\(event.arguments.longitude)"
        
        //invoke an http request against the air quality api
        let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
        
        defer {
            try? httpClient.syncShutdown()
        }
        
        let request = try HTTPClient.Request(url: url, method: .GET)

        let response = try httpClient.execute(request: request).wait()

        //decode the results of the air quality api call
        let jsonResponse = try decoder.decode(APIRepsonse.self, from: response.body!)

        //convert the temperature from celsius to fahrenheight
        let temperature = round((jsonResponse.data.current.weather.tp * 9 / 5) + 32)
        
        //initiate the callback to the function
        callback(.success(Output(
                temperature: temperature,
                aqIndex: jsonResponse.data.current.pollution.aqius,
                latitude: event.arguments.latitude,
                longitude: event.arguments.longitude)
            )
        )
        
    } catch let err {
        print(err)
        callback(.failure(err))
    }
}

//function to retrieve function environment variables by name
func getEnvVariable(name: String) throws -> String {
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    throw APIError.apiError
}
