// swiftlint:disable all
import Amplify
import Foundation

extension VehicleMessage {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case owner
    case timestamp
    case message
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let vehicleMessage = VehicleMessage.keys
    
    model.authRules = [
      rule(allow: .public, operations: [.create, .update, .delete, .read])
    ]
    
    model.pluralName = "VehicleMessages"
    
    model.fields(
      .id(),
      .field(vehicleMessage.owner, is: .required, ofType: .string),
      .field(vehicleMessage.timestamp, is: .required, ofType: .dateTime),
      .field(vehicleMessage.message, is: .required, ofType: .string)
    )
    }
}