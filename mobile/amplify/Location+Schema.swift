// swiftlint:disable all
import Amplify
import Foundation

extension Location {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case latitude
    case longitude
    case name
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let location = Location.keys
    
    model.listPluralName = "Locations"
    model.syncPluralName = "Locations"
    
    model.fields(
      .field(location.latitude, is: .required, ofType: .double),
      .field(location.longitude, is: .required, ofType: .double),
      .field(location.name, is: .required, ofType: .string)
    )
    }
}