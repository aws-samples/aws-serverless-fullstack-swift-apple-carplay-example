// swiftlint:disable all
import Amplify
import Foundation

extension Place {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case address
    case latitude
    case longitude
    case name
    case placeType
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let place = Place.keys
    
    model.listPluralName = "Places"
    model.syncPluralName = "Places"
    
    model.fields(
      .field(place.address, is: .required, ofType: .string),
      .field(place.latitude, is: .required, ofType: .double),
      .field(place.longitude, is: .required, ofType: .double),
      .field(place.name, is: .required, ofType: .string),
      .field(place.placeType, is: .required, ofType: .enum(type: PlaceType.self))
    )
    }
}