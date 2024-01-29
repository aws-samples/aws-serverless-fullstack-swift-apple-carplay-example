// swiftlint:disable all
import Amplify
import Foundation

extension Message {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case id
    case recipient
    case text
    case timestamp
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let message = Message.keys
    
    model.listPluralName = "Messages"
    model.syncPluralName = "Messages"
    
    model.fields(
      .field(message.id, is: .required, ofType: .string),
      .field(message.recipient, is: .required, ofType: .string),
      .field(message.text, is: .required, ofType: .string),
      .field(message.timestamp, is: .required, ofType: .dateTime)
    )
    }
}