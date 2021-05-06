// swiftlint:disable all
import Amplify
import Foundation

public struct VehicleMessage: Model {
  public let id: String
  public var owner: String
  public var timestamp: Temporal.DateTime
  public var message: String
  
  public init(id: String = UUID().uuidString,
      owner: String,
      timestamp: Temporal.DateTime,
      message: String) {
      self.id = id
      self.owner = owner
      self.timestamp = timestamp
      self.message = message
  }
}