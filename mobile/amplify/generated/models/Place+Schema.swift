// swiftlint:disable all
import Amplify
import Foundation

extension Place {
  // MARK: - CodingKeys 
   public enum CodingKeys: String, ModelKey {
    case placeType
    case name
    case address
    case latitude
    case longitude
  }
  
  public static let keys = CodingKeys.self
  //  MARK: - ModelSchema 
  
  public static let schema = defineSchema { model in
    let place = Place.keys
    
    model.pluralName = "Places"
    
    model.fields(
      .field(place.placeType, is: .required, ofType: .enum(type: PlaceType.self)),
      .field(place.name, is: .required, ofType: .string),
      .field(place.address, is: .required, ofType: .string),
      .field(place.latitude, is: .required, ofType: .double),
      .field(place.longitude, is: .required, ofType: .double)
    )
    }
}