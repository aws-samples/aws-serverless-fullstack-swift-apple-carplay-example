import Amplify
import Foundation

// service to subscribe to vehicle messages

// protocol is used to publish messages to CarPlay as CarPlay does not support the ObservableObject construct
protocol VehicleMessageServiceDelegate: AnyObject {
    func vehicleMessageService(message: String)
}

class VehicleMessageService: NSObject, ObservableObject {
    
    // in a production app this will come from the authenticated username or vehicle registration
    // for this sample we will hard code the vehicle identifier
    let owner = "Vehicle1"
    
    weak var delegate:VehicleMessageServiceDelegate?
    var subscription: AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<VehicleMessage>> = AmplifyAsyncThrowingSequence<GraphQLSubscriptionEvent<VehicleMessage>>()
    
    override init() {
        super.init()
        startSubscription()
    }
    
    // ObservedObject for iOS views to subscribe to for new messages as they are received from the Cloud
    // messages is an array of all messages received from the subscription
    @Published var messages: [VehicleMessage] = [VehicleMessage]()
    
    func startSubscription() {
        subscription = Amplify.API.subscribe(request: .onCreateVehicleMessage(owner: owner))
        Task {
            do {
                for try await subscriptionEvent in subscription {
                    switch subscriptionEvent {
                    case .connection(let subscriptionConnectionState):
                        print("Subscription connect state is \(subscriptionConnectionState)")
                    case .data(.success(let createdItem)):
                        print("Successfully received message from subscription")
                        DispatchQueue.main.async {
                            self.messages.append(createdItem)
                            self.delegate?.vehicleMessageService(message: createdItem.message)
                        }
                    case .data(.failure(let error)):
                        print("Failed subscription result with \(error.errorDescription)")
                    }
                }
            } catch {
                print("Subscription has terminated with \(error)")
            }
        }
    }
    
    func cancelSubscription() {
        print("Cancelling subscription")
        subscription.cancel();
    }
}
