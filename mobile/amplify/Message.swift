// swiftlint:disable all
import Amplify
import Foundation

public struct Message: Model {
  public let id: String
  public var recipient: String
  public var timestamp: Temporal.DateTime
  public var text: String
  
  public init(id: String = UUID().uuidString,
      recipient: String,
      timestamp: Temporal.DateTime,
      text: String) {
      self.id = id
      self.recipient = recipient
      self.timestamp = timestamp
      self.text = text
  }
}
