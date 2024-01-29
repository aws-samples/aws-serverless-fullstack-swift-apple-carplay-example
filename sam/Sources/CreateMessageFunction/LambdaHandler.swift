import AWSLambdaRuntime
import Foundation

// define struct for function event arguments
struct Event: Codable {
    let arguments: Arguments
}

struct Arguments: Codable {
    let recipient: String
    let text: String
}

// define struct for the output of the lambda function
struct Message: Codable {
    let recipient: String
    let text: String
    let id: String
    let timestamp: String
}

@main
struct CreateMessageFunction: SimpleLambdaHandler {

    // function handler
    func handle(_ event: Event, context: LambdaContext) async throws -> Message {
    
        print("received event: \(event)")

        let dateFormatter = DateFormatter();
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS" 

        return Message(
            recipient: event.arguments.recipient,
            text: event.arguments.text,
            id: UUID().uuidString,
            timestamp: "\(dateFormatter.string(from: Date.now))Z"
        )
    }
}
