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

// define function error types
enum FunctionError: Error {
    case envError
}

// define an AWS Secrets Manager client
let secretsManagerClient = try SecretsManagerClient()

Lambda.run { (context, event: Event, callback: @escaping (Result<Output, Error>) -> Void) in

    do {
        
        // get lambda function environment variables for api endpoint and secret key name
        let apiEndpoint = try getEnvVariable(name: "API_ENDPOINT")
        let apiKeySecretName = try getEnvVariable(name: "API_KEY_SECRET_NAME")
        
        // get the latitude and longitude passed to the function as an event
        let latitude = event.arguments.latitude
        let longitude = event.arguments.longitude
        
        // call function to retrieve the weather api key from Secrets Manager
        getAPIKey(secretId: apiKeySecretName) { result in
            
            switch(result) {
            case .success(let apiKey):

                // call function to call the weather api and return the results
                callAPI(apiEndpoint: apiEndpoint, apiKey: apiKey, latitude: latitude, longitude: longitude) { result in
                    
                    switch(result) {
                    case .success(let output):
                        callback(.success(output))
                    case .failure(let err):
                        callback(.failure(err))
                    }
                }

            case .failure(let err):
                callback(.failure(err))
            }
        }
    } catch let err {
        callback(.failure(err))
    }
}

// function to retrieve the api key from SecretsManager
func getAPIKey (secretId: String, callback: @escaping ((Result<String, Error>)) -> Void) {
    
    let input = GetSecretValueInput(secretId: secretId)
    
    secretsManagerClient.getSecretValue(input: input) { result in
        switch(result) {
        case .success(let output):
            callback(.success(output.secretString!))
        case .failure(let err):
            callback(.failure(err))
        }
    }
}

// function to make a restfull call to the weather api
func callAPI (apiEndpoint: String, apiKey: String, latitude: Double, longitude: Double, callback: @escaping ((Result<Output, Error>)) -> Void) {
    
    do {
        
        //decoder to parse the air quality api result
        let decoder = JSONDecoder()
        
        //construct the url for the air quality api call with the api key, latitude, and longitude
        let url = "\(apiEndpoint)?key=\(apiKey)&lat=\(latitude)&lon=\(longitude)"
        
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
                latitude: latitude,
                longitude: longitude
                )
            )
        )
    } catch (let err) {
        callback(.failure(err))
    }
}

//function to retrieve function environment variables by name
func getEnvVariable(name: String) throws -> String {
    
    if let value = ProcessInfo.processInfo.environment[name] {
        return value
    }
    
    throw FunctionError.envError
}
