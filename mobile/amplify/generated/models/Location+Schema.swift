// swiftlint:disable all
import Amplify
import Foundation

extension Location {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case name
    case latitude
    case longitude
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let location = Location.keys
    
    model.pluralName = "Locations"
    
    model.fields(
      .field(location.name, is: .required, ofType: .string),
      .field(location.latitude, is: .required, ofType: .double),
      .field(location.longitude, is: .required, ofType: .double)
    )
    }
}