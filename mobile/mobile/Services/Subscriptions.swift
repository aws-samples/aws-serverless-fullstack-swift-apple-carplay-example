import Amplify

// Appsync GraphQL subscription request for vehicle messages
extension GraphQLRequest {
    
    static func onCreateVehicleMessage(owner: String) -> GraphQLRequest<VehicleMessage> {
        let operationName = "onCreateVehicleMessage"
        let document = """
        subscription \(operationName)($owner: String!) {
          \(operationName)(owner: $owner) {
            id
            message
            owner
            timestamp
          }
        }
        """
        
        return GraphQLRequest<VehicleMessage>(
            document: document,
            variables: ["owner": owner],
            responseType: VehicleMessage.self,
            decodePath: operationName)
    }
}
