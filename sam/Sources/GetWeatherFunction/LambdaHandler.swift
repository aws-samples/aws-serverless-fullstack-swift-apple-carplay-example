import AWSLambdaRuntime
import AsyncHTTPClient
import Foundation
import AWSSecretsManager

//structure for Lambda Event arguments
struct Event: Codable {
    let arguments: Arguments
}

struct Arguments: Codable {
    let latitude: Double
    let longitude: Double
}

//structure for the lambda function output
struct WeatherIndex : Codable {
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

// define function error types
enum FunctionError: Error {
    case envError
    case apiError
    case secretError
}

@main
struct GetWeatherFunction: SimpleLambdaHandler {

    // function handler
    func handle(_ event: Event, context: LambdaContext) async throws -> WeatherIndex {

        print("received event: \(event)")

        // get lambda function environment variables for api endpoint and secret key name
        let apiEndpoint = try getEnvVariable(name: "API_ENDPOINT")
        let apiKeySecretArn = try getEnvVariable(name: "API_KEY_SECRET_ARN")

        // lookup the api key in Secrets Manager
        let apiKey = try await getAPIKey(secretId: apiKeySecretArn)
     
        // call the weather api to obtain temperature and air quality for the requested latitude and longitude
        let response = try await callAPI(
            apiEndpoint: apiEndpoint, 
            apiKey: apiKey, 
            latitude: event.arguments.latitude, 
            longitude: event.arguments.longitude
        )
        
        return response
    }
}

// function to retrieve the api key from SecretsManager
func getAPIKey (secretId: String) async throws -> String {
    
    do {

        let secretsManagerClient = try await SecretsManagerClient()
        let input = GetSecretValueInput(secretId: secretId)
        
        let result = try await secretsManagerClient.getSecretValue(input: input)
        
        return result.secretString!

    } catch {
        print("Secrets Manager Error: \(error)")
        throw FunctionError.secretError
    }
}

// function to make a restfull call to the weather api
func callAPI (apiEndpoint: String, apiKey: String, latitude: Double, longitude: Double) async throws -> WeatherIndex {
    
    let httpClient = HTTPClient(eventLoopGroupProvider: .singleton)

    do {
        
        //construct the url for the air quality api call with the api key, latitude, and longitude
        let url = "\(apiEndpoint)?key=\(apiKey)&lat=\(latitude)&lon=\(longitude)"
        
        // call the rest api
        let request = HTTPClientRequest(url: url)
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        let body = try await response.body.collect(upTo: 1024 * 1024)

        //decode the results of the air quality api call
        let jsonResponse = try JSONDecoder().decode(APIRepsonse.self, from: body)
        
        //convert the temperature from celsius to fahrenheight
        let temperature = round((jsonResponse.data.current.weather.tp * 9 / 5) + 32)
        
        try await httpClient.shutdown()

        // return the output
        return WeatherIndex(
                temperature: temperature,
                aqIndex: jsonResponse.data.current.pollution.aqius,
                latitude: latitude,
                longitude: longitude
        )
    
    } catch {
        print("API Error: \(error)")
        try await httpClient.shutdown()
        throw FunctionError.apiError
    }
}

//function to retrieve function environment variables by name
func getEnvVariable(name: String) throws -> String {
    
    guard let value = ProcessInfo.processInfo.environment[name] else {
        throw FunctionError.envError
    }
    
    return value
}
