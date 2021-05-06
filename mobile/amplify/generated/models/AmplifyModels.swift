// swiftlint:disable all
import Amplify
import Foundation

// Contains the set of classes that conforms to the `Model` protocol. 

final public class AmplifyModels: AmplifyModelRegistration {
  public let version: String = "2a3fc309c7155c66e57c31d87748dd1d"
  
  public func registerModels(registry: ModelRegistry.Type) {
    ModelRegistry.register(modelType: VehicleMessage.self)
  }
}