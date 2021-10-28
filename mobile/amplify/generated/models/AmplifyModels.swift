// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "348bf1e17edc6d6382f1b0261d8c585e"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: VehicleMessage.self)
  }
}