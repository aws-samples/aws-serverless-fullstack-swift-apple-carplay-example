import Amplify

// Appsync GraphQL subscription request for vehicle messages
extension GraphQLRequest {
    
    static func onCreateMessage(recipient: String) -> GraphQLRequest<Message> {
        let operationName = "onCreateMessage"
        let document = """
        subscription \(operationName) {
          \(operationName)(recipient: "\(recipient)") {
            id
            text
            recipient
            timestamp
          }
        }
        """
        
        return GraphQLRequest<Message>(
            document: document,
            responseType: Message.self,
            decodePath: operationName)
    }
}

